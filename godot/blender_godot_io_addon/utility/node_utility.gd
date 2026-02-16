@tool
class_name BlenderNodes

static func apply_param(node: Node, key: String, value: Variant) -> Error:
	# TODO(@melvspace): separate applying params per strategy. 
	# Example - ImporterMeshInstance3D strategy should create lazy node and 
	# maybe also parse `gi_mode: Dynamic` to `gi_mode: 2`
	if node is ImporterMeshInstance3D:
		var apply_later: ApplyLaterNode = _find_apply_later(node)
		if not apply_later:
			apply_later = ApplyLaterNode.new()
			node.add_child(apply_later)
			apply_later.name = "_ApplyParamsLater"
			apply_later.owner = node.owner
			
		apply_later.extras[key] = value

	_recursive_set(node, key, value)
	return OK


static func _recursive_set(object: Object, key: String, value: Variant):
	var parts = key.split('.')
	if parts.size() == 1:
		var object_value = object.get(key)
		if value is String and (value.begins_with("res://") or value.begins_with("uid://")):
			value = load(value)
		
		value = _handle_special_types(object_value, value)

		print("Set %s to %s on %s" % [key, value, object])
		object.set(parts[0], value)
		return
	
	print("Recursive set %s to %s on %s" % [key, value, object])
	
	var property_key = parts[0]
	parts.remove_at(0)
	
	var property_object = object.get(property_key)
	if not property_object:
		var property_list = object.get_property_list()
		var property_index = -1
		for i in range(property_list.size()):
			if property_list[i].get("name") == property_key:
				property_index = i
				break
		
		if property_index != -1:
			var property = property_list[property_index]
			if property.get("hint") == PROPERTY_HINT_RESOURCE_TYPE:
				var class_list = ProjectSettings.get_global_class_list()
				var resource_type = property.get("hint_string")
				var resource_definition_index = -1
				for i in range(class_list.size()):
					if class_list[i].get("class") == resource_type:
						resource_definition_index = i
						break
				
				if resource_definition_index != -1:
					var resource_path = class_list[resource_definition_index].get("path")
					var resource = load(resource_path).new()
					object.set(property_key, resource)
					property_object = resource
			
	if property_object and property_object is Object:
		_recursive_set(property_object, ".".join(parts), value)


static func _find_apply_later(node: Node) -> Node:
	for child in node.get_children():
		if child is ApplyLaterNode:
			return child
			
	return null


static func _handle_special_types(object_value: Variant, value: Variant):
	if object_value is Vector4 and value is Array and value.size() == 4:
		value = Vector4(value[0], value[1], value[2], value[3])
		
	elif object_value is Vector3 and value is Array and value.size() == 3:
		value = Vector3(value[0], value[1], value[2])
		
	elif object_value is Vector2 and value is Array and value.size() == 2:
		value = Vector2(value[0], value[1])
		
	elif object_value is Quaternion:
		if value is Array:
			if value.size() == 3:
				# Euler to Quaternion (assuming degrees, typical for Blender)
				value = Quaternion.from_euler(Vector3(deg_to_rad(value[0]), deg_to_rad(value[1]), deg_to_rad(value[2])))
			elif value.size() == 4:
				value = Quaternion(value[0], value[1], value[2], value[3])

	return value
