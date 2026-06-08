@tool
class_name GGP_NodeModifier extends Resource

@export
var enabled: bool = true

## Remove `.001` from names
func _get_name_from_gltf(gltf_node: GLTFNode) -> String:
	var regex = RegEx.new()
	regex.compile(r"\.\d+$")
	
	return regex.sub(gltf_node.original_name, "")
	
## Remove `_001` from names
func _get_name_from_node(node: Node) -> String:
	var regex = RegEx.new()
	regex.compile(r"_\d+$")
	
	return regex.sub(node.name, "")


func _get_extras(gltf_node: GLTFNode) -> Dictionary:
	if "extras" in gltf_node.get_meta_list():
		return gltf_node.get_meta("extras")
		
	return {}


func _apply_later(node: Node, properties: Dictionary[String, Variant]):
	var apply_later_node = node.find_child("_ApplyLater")
	if not apply_later_node or apply_later_node is not GGP_ImporterMeshInstance3D_ApplyLater:
		apply_later_node = GGP_ImporterMeshInstance3D_ApplyLater.new()
		node.add_child(apply_later_node)
		
		apply_later_node.owner = node.owner
		apply_later_node.name = "_ApplyLater"
	
	apply_later_node = apply_later_node as GGP_ImporterMeshInstance3D_ApplyLater
	apply_later_node.properties["gi_mode"] = MeshInstance3D.GIMode.GI_MODE_DYNAMIC


## Runs before any node generated
func pre_generate(state: GLTFState) -> Error:
	return OK


## Creates node from GLTF node information
func generate_node(state: GLTFState, gltf_node: GLTFNode, scene_parent: Node, node: Node) -> Node:
	return node


## Post-processing of generated node
func process_node(state: GLTFState, gltf_node: GLTFNode, json: Dictionary, node: Node) -> Node:
	return node


## Finalize scene node tree	
func process_scene(state: GLTFState, root: Node) -> Error:
	return OK
