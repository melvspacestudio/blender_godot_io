@tool
class_name ReuseTextures extends NodeModifier

@export_dir
var textures_path: String = ""

func _should_process(node: Node) -> bool:
	return node is ImporterMeshInstance3D


func _process_node(node: Node) -> Node:
	if textures_path.is_empty():
		push_warning("Textures Path not set.")
		return node
	
	if node is ImporterMeshInstance3D:
		var mesh_instance = node as ImporterMeshInstance3D
		var surface_count = mesh_instance.mesh.get_surface_count()
		for i in range(surface_count):
			var material = mesh_instance.mesh.get_surface_material(i)
			if material is StandardMaterial3D:
				# TODO: Implement texture reuse logic here
				pass

	return node
