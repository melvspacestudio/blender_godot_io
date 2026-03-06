@tool
class_name BGIO_NodeUtility


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
	
	if node.get_parent():
		node.add_sibling(new_node)

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
	
	node.queue_free() # Use queue_free instead of free for safety

	new_node.owner = node_owner
	new_node.name = node_name
	new_node.set_meta("extras", node_meta)
