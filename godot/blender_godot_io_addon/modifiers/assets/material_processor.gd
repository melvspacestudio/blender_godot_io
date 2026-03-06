@tool
class_name BGIO_Material_NodeModifier extends BGIO_NodeModifier

@export_dir
var material_dir: String = "assets/materials"


func _get_material_dir() -> String:
	if material_dir.begins_with("res://"):
		return material_dir
		
	if not material_dir.begins_with("/"):
		var resource_dir = resource_path.replace("res://", "").split("/")
		resource_dir.remove_at(resource_dir.size() - 1)
		
		return "res://" + "/".join(resource_dir).path_join(material_dir)

	return material_dir


func pre_generate(state: GLTFState) -> Error:
	if not material_dir:
		push_warning("Material directory is not set for %s" % [self])
		return ERR_SKIP
	
	var materials: Array[Material] = state.get_materials()
	var new_materials: Array[Material] = []
	
	var json_materials = state.json.get("materials", [])
	
	for i in len(materials):
		var material = materials[i]
		var name = json_materials[i]["name"]
		
		var path = _get_material_dir().path_join(name + ".tres")
		if not ResourceLoader.exists(path):
			ResourceSaver.save(material, path)
			
		material.set_meta("material_path", path)
	
	return OK
	
func generate_node(state: GLTFState, gltf_node: GLTFNode, scene_parent: Node, node: Node) -> Node:
	var mesh_id = gltf_node.mesh
	if mesh_id == -1: return node
	
	var mesh: GLTFMesh = state.get_meshes()[mesh_id]
	var importer_mesh: ImporterMesh = mesh.mesh
	
	for surface in importer_mesh.get_surface_count():
		var material = importer_mesh.get_surface_material(surface)
		var material_path = material.get_meta("material_path", "")
		
		if material_path:
			importer_mesh.set_surface_material(surface, load(material_path))
	
	return node
	
#func process_node(state: GLTFState, gltf_node: GLTFNode, json: Dictionary, node: Node) -> Node:
	#if node is ImporterMeshInstance3D:
		#var mesh: ImporterMesh = node.mesh
		#var gltf_mesh: GLTFMesh = state.get_meshes()[gltf_node.mesh]
		#
		#for mat in gltf_mesh.instance_materials:
			#print(["GLTF", mat.get_meta_list()])
		#
		#for surface_index in mesh.get_surface_count():
			#var mat = mesh.get_surface_material(surface_index)
			#print(["Surface", mat.get_meta_list()])
			#print(["Mesh -> Surface", mesh.get_mesh().surface_get_material(surface_index).get_meta_list()])
	#
	#return node
