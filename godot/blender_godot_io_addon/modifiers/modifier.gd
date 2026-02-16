@tool
class_name NodeModifier extends Resource

@export
var enabled: bool = true

## virtual
func _should_process(_node: Node) -> bool:
	return false

## Check if the node should be processed by this modifier
## 
## @param node: The node to check
## @return: True if the node should be processed, False otherwise
func should_process(node: Node) -> bool:
	return enabled and _should_process(node)


## virtual
## This is the main processing logic for the modifier.
## Renamed from _process to avoid confusion with Godot's built-in _process(delta).
func _process_node(node: Node) -> Node:
	return node
	

## Process the node with the given extras
## 
## @param node: The node to process
## @return: The processed node
func process(node: Node) -> Node:
	if not enabled:
		return node

	return _process_node(node)


func _log(message: String) -> void:
	var script: Script = get_script()
	var script_name: String = "NodeModifier"
	if script is GDScript:
		var global_name = script.get_global_name()
		if not global_name.is_empty():
			script_name = global_name
		else:
			script_name = script.resource_path.get_file()
			
	print("[%s]: %s" % [script_name, message])


func _get_extras(node: Node) -> Dictionary:
	return node.get_meta("extras", {})

	
func _write_extras(node: Node, key: String, value: Variant) -> void:
	var dict: Dictionary = _get_extras(node)
	dict[key] = value
	node.set_meta("extras", dict)


## Replaces a node with a new node, transferring all children and preserving the original node's name
## 
## @param node The original node to be replaced
## @param new_node The new node that will replace the original node
## @param extras Optional extras dictionary to set on the new node. If null, copies from original node.
## @param skip_children If true, children are NOT transferred to the new node.
func _replace_node(node: Node, new_node: Node, extras: Variant = null, skip_children: bool = true) -> void:
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
	
	if node is Node3D and new_node is Node3D:
		new_node.transform = node.transform
	
	node.queue_free() # Use queue_free instead of free for safety

	new_node.owner = node_owner
	new_node.name = node_name
	new_node.set_meta("extras", node_meta)
