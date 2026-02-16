@tool
class_name ReplaceParent extends NodeModifier

const EXTRAS_REPLACE_PARENT = &"replace_parent"

func _should_process(node: Node) -> bool:
	var extras = _get_extras(node)
	var replace_parent = extras.get(EXTRAS_REPLACE_PARENT, false)
	if not replace_parent:
		return false

	if node.get_parent() == null or node.get_parent().owner == null:
		push_warning("Cant replace root node of scene for now")
		return false

	return true


func _process_node(node: Node) -> Node:
	var parent = node.get_parent()
	if not parent:
		return node
		
	# Store parent transform if both are Node3D
	var parent_transform := Transform3D.IDENTITY
	if parent is Node3D:
		parent_transform = parent.transform
	
	var owner = parent.owner
	
	# We want to replace the parent with this node
	# First, let's remove this node from the parent
	parent.remove_child(node)
	
	# Now replace the parent with this node in the hierarchy
	# _replace_node handles sibling placement, name, owner, and transform
	# skip_children = false because we want to keep parent's OTHER children too?
	# Actually, the original code did parent.replace_by(node) which transfers children
	
	_replace_node(parent, node, null, false)
	
	# Adjust transform if it's a Node3D
	if node is Node3D:
		node.transform = parent_transform * node.transform
	
	return node
