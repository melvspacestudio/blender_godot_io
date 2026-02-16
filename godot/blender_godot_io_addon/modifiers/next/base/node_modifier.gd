@tool
class_name BGIO_NodeModifier extends Resource

## Remove `.001` from names
func _get_name(gltf_node: GLTFNode) -> String:
	var regex = RegEx.new()
	regex.compile(r"\.\d+$")
	
	return regex.sub(gltf_node.original_name, "")
	
func _get_extras(gltf_node: GLTFNode) -> Dictionary:
	if "extras" in gltf_node.get_meta_list():
		return gltf_node.get_meta("extras")
		
	return {}


## Creates node from GLTF node information
func _generate_node(state: GLTFState, gltf_node: GLTFNode, scene_parent: Node, node: Node) -> Node:
	return node


## Post-processing of generated node
func _process_node(node: Node) -> Node:
	return node
