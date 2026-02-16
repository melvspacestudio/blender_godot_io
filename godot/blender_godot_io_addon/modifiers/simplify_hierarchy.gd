## Removes redundant nodes in hierarchy
## 
## ! Will break animations
@tool
class_name SimplifyHierarchy extends NodeModifier

func _should_process(node: Node) -> bool:
	if not node.owner:
		return false

	var is_simple_node = node.get_class() == "Node3D"
	if not is_simple_node:
		return false

	if node.get_child_count() == 1:
		var child = node.get_child(0)
		if child is Node3D:
			return true
		
	return false


func _process_node(node: Node) -> Node:
	var node_3d = node as Node3D
	var node_name = node.name
	var child = node.get_child(0) as Node3D
	var parent = node.get_parent()
	
	if not parent:
		return node
		
	var transform = node_3d.transform
	
	_log("Will replace %s with its child %s" % [node_name, child.name])
	
	var child_transform = transform * child.transform
	var node_owner = node.owner
	
	node.remove_child(child)
	
	# We can use _replace_node here if we are careful, 
	# but since we already removed the child, it's safe.
	_replace_node(node, child, null, false)
	
	child.transform = child_transform
	child.name = node_name # Keep the parent's name usually preferred for organization
	
	return child
