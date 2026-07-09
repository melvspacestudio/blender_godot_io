@tool
class_name GGP_Material_NodeModifier extends GGP_NodeModifier

@export_dir
var material_dir: String = "assets/materials"

@export
var overwrite_existing: bool = false


func _get_material_dir() -> String:
	return GGP_AssetProcessor_Utility.resolve_output_dir(resource_path, material_dir)


func pre_generate(state: GLTFState) -> Error:
	if not material_dir:
		push_warning("Material directory is not set for %s" % [self])
		return ERR_SKIP

	var resolved_material_dir := _get_material_dir()
	var dir_error := GGP_AssetProcessor_Utility.ensure_output_dir(resolved_material_dir)
	if dir_error != OK:
		push_warning("Could not create material directory `%s`: %s. Skipping material extraction." % [resolved_material_dir, error_string(dir_error)])
		return ERR_SKIP

	var materials: Array[Material] = state.get_materials()
	var json_materials := GGP_AssetProcessor_Utility.get_json_array(state.json, "materials", "GGP_Material_NodeModifier")

	for i in materials.size():
		var material := materials[i]
		if material == null:
			push_warning("Skipping null material at runtime material index %d." % [i])
			continue

		var name := GGP_AssetProcessor_Utility.get_safe_stem_from_json(json_materials, i, "materials", "material", "GGP_Material_NodeModifier")
		var path := resolved_material_dir.path_join(name + ".tres")
		if overwrite_existing or not GGP_AssetProcessor_Utility.resource_file_exists(path):
			var save_error := ResourceSaver.save(material, path)
			if save_error != OK:
				push_warning("Could not save material `%s`: %s. Skipping runtime material index %d." % [path, error_string(save_error), i])
				continue

		if GGP_AssetProcessor_Utility.resource_file_exists(path):
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
