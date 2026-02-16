@tool
class_name SanitizeNames extends NodeModifier

var _regex: RegEx

func _init() -> void:
	_regex = RegEx.new()
	_regex.compile("_\\d+$")

func _should_process(_node: Node) -> bool:
	return true


func _process_node(node: Node) -> Node:
	if not _regex:
		_regex = RegEx.new()
		_regex.compile("_\\d+$")
		
	node.name = _regex.sub(node.name, "", true)
	return node
