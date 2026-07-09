@tool
## This modifier removes nodes with "-discard" tag
class_name GGP_DiscardNodeModifier extends GGP_NodeModifier

func process_node(state: GLTFState, gltf_node: GLTFNode, json: Dictionary, node: Node) -> Node:
	if _get_name_from_node(node).to_lower().ends_with("-discard"):
		node.free()

	return node
