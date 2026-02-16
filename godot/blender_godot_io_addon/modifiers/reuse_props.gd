@tool
class_name ReuseProps extends NodeModifier

const EXTRAS_PACKED_SCENE = &"packed_scene"

@export_dir
var props_path: String = ""

@export
var force_override: bool = false

var _regex: RegEx

func _init() -> void:
	_regex = RegEx.new()
	_regex.compile("_\\d+$")


func _should_process(node: Node) -> bool:
	return node.name.begins_with("P_")


func _process_node(node: Node) -> Node:
	if props_path.is_empty():
		push_warning("Props Path not set.")
		return node
		
	var scene_name = node.name.substr(2)
	if not _regex:
		_regex = RegEx.new()
		_regex.compile("_\\d+$")
		
	scene_name = _regex.sub(scene_name, "", true)
	
	# ResourceLoader.list_directory might not exist in all Godot versions or might be slow
	# Assuming it works here as it was in original code
	for prop_name in ResourceLoader.list_directory(props_path):
		if prop_name.begins_with(scene_name):
			var path = "%s/%s" % [props_path, prop_name]
			var new_node = Node3D.new()
			node.add_child(new_node)
			new_node.owner = node.owner
			new_node.name = prop_name.get_basename()
			_write_extras(new_node, EXTRAS_PACKED_SCENE, path)
			return new_node
	
	return node
