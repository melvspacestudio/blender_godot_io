@tool
class_name ReuseMaterials extends NodeModifier

@export_dir
var materials_path: String = ""

@export
var force_override: bool = false

@export
var skip_material: Material

func _should_process(node: Node) -> bool:
	return node is ImporterMeshInstance3D


func _process_node(node: Node) -> Node:
	if materials_path.is_empty():
		push_warning("Materials Path not set.")
		return node
	
	if node is ImporterMeshInstance3D:
		var mesh_instance = node as ImporterMeshInstance3D
		var surface_count = mesh_instance.mesh.get_surface_count()
		
		for i in range(surface_count):
			var material = mesh_instance.mesh.get_surface_material(i)
			if not material:
				continue
				
			var res_name = material.resource_name
			if res_name.begins_with("M_"):
				var material_basename = res_name.substr(2)
				
				if res_name.ends_with("-skip"):
					if not skip_material:
						push_warning("Unable to skip material %s on %s" % [node.name, res_name])
						continue

					mesh_instance.mesh.set_surface_material(i, skip_material)
					continue
				
				var material_path = "%s/%s.tres" % [materials_path, material_basename]
				
				if force_override or not ResourceLoader.exists(material_path):
					material.take_over_path(material_path)
					ResourceSaver.save(material, material_path, ResourceSaver.FLAG_CHANGE_PATH)
				
				var saved_material = load(material_path)
				if saved_material is Material:
					mesh_instance.mesh.set_surface_material(i, saved_material)

	return node
