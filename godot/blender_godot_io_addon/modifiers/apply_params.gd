@tool
class_name ApplyParams extends NodeModifier


func _should_process(node: Node) -> bool:
	var extras = _get_extras(node)
	return not extras.is_empty()


func _process_node(node: Node) -> Node:
	var extras = _get_extras(node)
		
	for key in extras.keys():
		BlenderNodes.apply_param(node, key, extras[key])

	return node
