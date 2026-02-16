## Represents a node type change modifier that can transform nodes between compatible types
## during a GLTF processing operation.
@tool
class_name ChangeType extends NodeModifier

var _regex: RegEx

func _init() -> void:
	_regex = RegEx.new()
	_regex.compile("_?\\d+$")


func _get_target_classname(node: Node) -> String:
	if not _regex:
		_regex = RegEx.new()
		_regex.compile("_?\\d+$")
	
	return _regex.sub(node.name, "", true)


func _should_process(node: Node) -> bool:
	if node is MeshInstance3D:
		return false

	var target_class = _get_target_classname(node)
	return ClassDB.class_exists(target_class)


func _process_node(node: Node) -> Node:
	var target_class = _get_target_classname(node)
	var new_node = ClassDB.instantiate(target_class)
	if not new_node:
		return node
		
	new_node.name = node.name
	
	if node is Node3D and new_node is Node3D:
		new_node.transform = (node as Node3D).transform

	for meta_item in node.get_meta_list():
		new_node.set_meta(meta_item, node.get_meta(meta_item))

	# Transfer children and replace
	_replace_node(node, new_node, null, false)

	return new_node
