@tool
class_name BGIO_ClassNodeModifier extends BGIO_NodeModifier

@export
var blacklist: Array[String] = []

func _get_classname(gltf_node: GLTFNode) -> String:
	var classname = _get_extras(gltf_node).get("class_name", _get_name(gltf_node))
	if classname is String and not classname.is_empty():
		if (ClassDB.class_exists(classname) and classname not in blacklist):
			return classname
			
	return ""
	

func _handle_empty_node(state: GLTFState, gltf_node: GLTFNode, scene_parent: Node, node: Node) -> Node:
	var classname = _get_classname(gltf_node)
	if classname:
		var new_node = ClassDB.instantiate(classname)
		if new_node is not Node:
			return null
			
		new_node.name = gltf_node.resource_name
		return new_node
		
	return null
	

func _handle_mesh_node(state: GLTFState, gltf_node: GLTFNode, scene_parent: Node, node: Node) -> Node:
	var generated_node = _handle_empty_node(state, gltf_node, scene_parent, node)
	if not generated_node: return node
	
	var mesh := state.get_meshes()[gltf_node.mesh].mesh
	var mesh_node = ImporterMeshInstance3D.new()
	mesh_node.mesh = mesh
	mesh_node.name = "MeshInstance3D"
	
	generated_node.add_child(mesh_node)
	
	return generated_node


func _generate_node(state: GLTFState, gltf_node: GLTFNode, scene_parent: Node, node: Node) -> Node:
	if node: return node
	
	if gltf_node.mesh == -1:
		var generated_node = _handle_empty_node(state, gltf_node, scene_parent, node)
		if generated_node: return generated_node
	else:
		var generated_node = _handle_mesh_node(state, gltf_node, scene_parent, node)
		if generated_node: return generated_node

	return null
