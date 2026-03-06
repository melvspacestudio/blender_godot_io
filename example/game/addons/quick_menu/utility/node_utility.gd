class_name QMNodeUtility extends Object

static func all_of(node: Node) -> Array[Node]:
	var nodes: Array[Node] = []
	nodes.append(node)
	
	for child in node.get_children():
		nodes.append_array(all_of(child))

	return nodes
