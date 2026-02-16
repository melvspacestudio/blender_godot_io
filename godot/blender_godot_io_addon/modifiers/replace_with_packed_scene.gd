@tool
class_name ReplaceWithPackedScene extends NodeModifier

const EXTRAS_PACKED_SCENE = &"packed_scene"

func _should_process(node: Node) -> bool:
	var extras = _get_extras(node)
	return extras.has(EXTRAS_PACKED_SCENE)


func _process_node(node: Node) -> Node:
	if node.get_parent() == null or node.get_parent().owner == null:
		push_warning("Cannot replace root node or node without owner")
		return node
	
	var parent = node.get_parent()
	
	# Workaround to fix collection instance translation
	# Often Blender collections are imported with an extra offset node
	var node_position := Vector3.ZERO
	if parent is Node3D and parent.get_child_count() > 0:
		var first_child = parent.get_child(0)
		if first_child is Node3D:
			node_position = first_child.position
			node_position = parent.quaternion * node_position
			
	var extras = _get_extras(node)
	var path = extras.get(EXTRAS_PACKED_SCENE)
	
	if ResourceLoader.exists(path):
		var packed_scene = load(path)
		if packed_scene is PackedScene:
			var new_node: Node = packed_scene.instantiate()
			
			if new_node is Node3D and parent is Node3D:
				new_node.position = parent.position + node_position
				new_node.quaternion = parent.quaternion
				new_node.scale = parent.scale
			
			# Transfer children from the placeholder node to the new instantiated scene
			# skip_children = false means transfer them
			_replace_node(parent, new_node, null, false)
			
			return new_node
		
	push_warning("Failed to replace %s with packed scene from %s" % [node.name, path])
	return node
