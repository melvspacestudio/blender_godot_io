@tool
class_name BGIO_LightModifier extends BGIO_NodeModifier


func process_node(state: GLTFState, gltf_node: GLTFNode, json: Dictionary, node: Node) -> Node:
	if node is Light3D:
		node.light_bake_mode = Light3D.BAKE_STATIC
		node.shadow_enabled = true
		
	return node
