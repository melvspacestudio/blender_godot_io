@tool
class_name GGP_NodeUtility

const IMPORTED_PROPERTY_APPLIED := "applied"
const IMPORTED_PROPERTY_SKIPPED_UNKNOWN := "skipped_unknown"
const IMPORTED_PROPERTY_SKIPPED_RESERVED := "skipped_reserved"
const IMPORTED_PROPERTY_FAILED := "failed"


## Remove `.001` from names
static func get_name_from_gltf(gltf_node: GLTFNode) -> String:
	var regex = RegEx.new()
	regex.compile(r"\.\d+$")

	return regex.sub(gltf_node.original_name, "")


## Remove `_001` from names
static func get_name_from_node(node: Node) -> String:
	var regex = RegEx.new()
	regex.compile(r"_\d+$")

	return regex.sub(node.name, "")


static func get_extras(gltf_node: GLTFNode) -> Dictionary:
	if "extras" in gltf_node.get_meta_list():
		return gltf_node.get_meta("extras")

	return {}


static func all_of(node: Node) -> Array[Node]:
	var nodes: Array[Node] = []
	nodes.append(node)

	for child in node.get_children():
		nodes.append_array(all_of(child))

	return nodes


static func apply_imported_property(object: Object, key: String, value: Variant, reserved_keys: Array[String] = []) -> Dictionary:
	if not is_instance_valid(object):
		return _imported_property_result(IMPORTED_PROPERTY_FAILED, key, "target object is not valid")
	if key.is_empty():
		return _imported_property_result(IMPORTED_PROPERTY_SKIPPED_UNKNOWN, key, "")
	if key in reserved_keys:
		return _imported_property_result(IMPORTED_PROPERTY_SKIPPED_RESERVED, key, "")

	var parts := key.split(".")
	return _apply_imported_property_parts(object, parts, key, value)


static func _recursive_set(object: Object, key: String, value: Variant) -> bool:
	var result := apply_imported_property(object, key, value)
	return result.get("status", "") == IMPORTED_PROPERTY_APPLIED


static func _apply_imported_property_parts(object: Object, parts: PackedStringArray, full_key: String, value: Variant) -> Dictionary:
	if parts.is_empty():
		return _imported_property_result(IMPORTED_PROPERTY_SKIPPED_UNKNOWN, full_key, "")

	var property_key := parts[0]
	var property := _find_property(object, property_key)
	if property.is_empty():
		return _imported_property_result(IMPORTED_PROPERTY_SKIPPED_UNKNOWN, full_key, "")
	if _is_read_only_property(property):
		return _imported_property_result(IMPORTED_PROPERTY_FAILED, full_key, "property `%s` is read-only" % property_key)

	if parts.size() == 1:
		var conversion := _convert_imported_value(object, property, value)
		if conversion.get("ok", false):
			object.set(property_key, conversion.get("value"))
			return _imported_property_result(IMPORTED_PROPERTY_APPLIED, full_key, "")

		return _imported_property_result(IMPORTED_PROPERTY_FAILED, full_key, conversion.get("reason", "value could not be converted"))

	var property_object = object.get(property_key)
	if not property_object:
		var instantiated := _instantiate_property_resource(property)
		if instantiated.get("ok", false):
			property_object = instantiated.get("value")
			object.set(property_key, property_object)
		else:
			return _imported_property_result(
				IMPORTED_PROPERTY_FAILED,
				full_key,
				"nested property `%s` is not an Object and could not be created: %s" % [property_key, instantiated.get("reason", "unknown reason")]
			)

	if property_object is not Object:
		return _imported_property_result(IMPORTED_PROPERTY_FAILED, full_key, "nested property `%s` is not an Object" % property_key)

	var next_parts := parts.duplicate()
	next_parts.remove_at(0)
	return _apply_imported_property_parts(property_object, next_parts, full_key, value)


static func _find_property(object: Object, key: String) -> Dictionary:
	for property in object.get_property_list():
		if property.get("name", "") == key and int(property.get("type", TYPE_NIL)) != TYPE_NIL:
			return property

	return {}


static func _is_read_only_property(property: Dictionary) -> bool:
	return (int(property.get("usage", 0)) & PROPERTY_USAGE_READ_ONLY) != 0


static func _convert_imported_value(object: Object, property: Dictionary, value: Variant) -> Dictionary:
	var key: String = property.get("name", "")
	var expected_type := int(property.get("type", TYPE_NIL))
	var object_value = object.get(key)
	var converted = value

	if converted is String and _is_resource_path(converted):
		if expected_type == TYPE_OBJECT or object_value is Object:
			var resource := _load_imported_resource(converted)
			if not resource.get("ok", false):
				return resource
			converted = resource.get("value")

	converted = _handle_special_types(object_value, converted, expected_type)
	if _is_value_compatible(converted, expected_type, property):
		return {"ok": true, "value": converted}

	return {
		"ok": false,
		"reason": "expected `%s`, got `%s`" % [_property_type_name(expected_type, property), type_string(typeof(converted))]
	}


static func _load_imported_resource(path: String) -> Dictionary:
	if not ResourceLoader.exists(path):
		return {"ok": false, "reason": "resource `%s` does not exist" % path}

	var resource := ResourceLoader.load(path)
	if not resource:
		return {"ok": false, "reason": "resource `%s` could not be loaded" % path}

	return {"ok": true, "value": resource}


static func _is_resource_path(value: String) -> bool:
	return value.begins_with("res://") or value.begins_with("uid://")


static func _handle_special_types(object_value: Variant, value: Variant, expected_type: int = TYPE_NIL) -> Variant:
	if (object_value is Vector4 or expected_type == TYPE_VECTOR4) and _is_number_array(value, 4):
		value = Vector4(value[0], value[1], value[2], value[3])

	elif (object_value is Vector3 or expected_type == TYPE_VECTOR3) and _is_number_array(value, 3):
		value = Vector3(value[0], value[1], value[2])

	elif (object_value is Vector2 or expected_type == TYPE_VECTOR2) and _is_number_array(value, 2):
		value = Vector2(value[0], value[1])

	elif object_value is Quaternion or expected_type == TYPE_QUATERNION:
		if value is Array:
			if _is_number_array(value, 3):
				# Euler to Quaternion (assuming degrees, typical for Blender)
				value = Quaternion.from_euler(Vector3(deg_to_rad(value[0]), deg_to_rad(value[1]), deg_to_rad(value[2])))
			elif _is_number_array(value, 4):
				value = Quaternion(value[0], value[1], value[2], value[3])

	return value


static func _is_number_array(value: Variant, expected_size: int) -> bool:
	if value is not Array or value.size() != expected_size:
		return false

	for item in value:
		if typeof(item) != TYPE_FLOAT and typeof(item) != TYPE_INT:
			return false

	return true


static func _is_value_compatible(value: Variant, expected_type: int, property: Dictionary) -> bool:
	if value == null:
		return true
	if expected_type == TYPE_NIL:
		return true
	if expected_type == TYPE_FLOAT and (typeof(value) == TYPE_FLOAT or typeof(value) == TYPE_INT):
		return true
	if expected_type == TYPE_INT and typeof(value) == TYPE_INT:
		return true
	if expected_type == TYPE_OBJECT:
		if value is not Object:
			return false
		var hint_string := str(property.get("hint_string", ""))
		if hint_string.is_empty():
			return true
		for resource_type in hint_string.split(",", false):
			if (value as Object).is_class(resource_type.strip_edges()):
				return true
		return false

	return typeof(value) == expected_type


static func _property_type_name(expected_type: int, property: Dictionary) -> String:
	if expected_type == TYPE_OBJECT and not str(property.get("hint_string", "")).is_empty():
		return str(property.get("hint_string", ""))

	return type_string(expected_type)


static func _instantiate_property_resource(property: Dictionary) -> Dictionary:
	if int(property.get("type", TYPE_NIL)) != TYPE_OBJECT:
		return {"ok": false, "reason": "property is not an Object"}
	if int(property.get("hint", PROPERTY_HINT_NONE)) != PROPERTY_HINT_RESOURCE_TYPE:
		return {"ok": false, "reason": "property has no resource type hint"}

	var resource_types := str(property.get("hint_string", "")).split(",", false)
	for resource_type_value in resource_types:
		var resource_type := resource_type_value.strip_edges()
		if resource_type.is_empty():
			continue

		if ClassDB.class_exists(resource_type) and ClassDB.can_instantiate(resource_type):
			return {"ok": true, "value": ClassDB.instantiate(resource_type)}

		for class_definition in ProjectSettings.get_global_class_list():
			if class_definition.get("class", "") != resource_type:
				continue

			var script = ResourceLoader.load(class_definition.get("path", ""))
			if script and script is Script and script.can_instantiate():
				return {"ok": true, "value": script.new()}

	return {"ok": false, "reason": "no instantiable resource type found"}


static func _imported_property_result(status: String, key: String, reason: String) -> Dictionary:
	return {
		"status": status,
		"key": key,
		"reason": reason,
	}

## Replaces a node with a new node, transferring all children and preserving the original node's name
##
## @param node The original node to be replaced
## @param new_node The new node that will replace the original node
## @param extras Optional extras dictionary to set on the new node. If null, copies from original node.
## @param skip_children If true, children are NOT transferred to the new node.
static func replace(node: Node, new_node: Node, extras: Variant = null, skip_children: bool = true) -> void:
	if not new_node:
		push_warning("Cant replace node to nothing")
		return

	var parent = node.get_parent()
	var node_index := node.get_index()

	# Workaround to fix collection instance translation
	# Often Blender collections are imported with an extra offset node
	var node_position := Vector3.ZERO
	if parent is Node3D and parent.get_child_count() > 0:
		var first_child = parent.get_child(0)
		if first_child is Node3D:
			node_position = first_child.position
			node_position = parent.quaternion * node_position

	if not skip_children:
		for child in node.get_children(true):
			var child_owner = child.owner
			node.remove_child(child)
			new_node.add_child(child, true)
			child.owner = child_owner

	var node_name: String = node.name
	var node_owner: Node = node.owner
	var node_meta: Dictionary = extras if extras is Dictionary else node.get_meta("extras", {})

	if new_node is Node3D and parent is Node3D:
		#print("Original node position: %s" % [node.position])
		#print("Target node position: %s" % [node_position])

		new_node.position = parent.position + node_position
		new_node.quaternion = parent.quaternion
		new_node.scale = parent.scale

	if node is Node3D and new_node is Node3D:
		new_node.transform = node.transform

	new_node.name = node_name
	new_node.set_meta("extras", node_meta)

	if parent:
		parent.remove_child(node)
		parent.add_child(new_node)
		parent.move_child(new_node, node_index)
		new_node.owner = node_owner

	node.queue_free() # Use queue_free instead of free for safety
