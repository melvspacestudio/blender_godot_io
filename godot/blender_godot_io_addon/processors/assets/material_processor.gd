@tool
class_name BGIO_MaterialProcessor extends BGIO_Processor

@export_dir
var material_dir: String = "assets/materials"

func _get_material_dir() -> String:
	if material_dir.begins_with("res://"):
		return material_dir
		
	if not material_dir.begins_with("/"):
		var resource_dir = resource_path.replace("res://", "").split("/")
		resource_dir.remove_at(resource_dir.size() - 1)
		
		return "res://" + "/".join(resource_dir)

	return material_dir

func _pre_generate(state: GLTFState) -> Error:
	if not material_dir:
		push_warning("Material directory is not set for %s" % [self])
		return ERR_SKIP
	
	var materials = state.get_materials()
	var json_materials = state.json["materials"]
	
	for i in len(materials):
		var material = materials[i]
		var name = json_materials[i]["name"]
		
		var path = _get_material_dir().path_join(name + ".tres")
		if not ResourceLoader.exists(path):
			ResourceSaver.save(material, path, ResourceSaver.FLAG_CHANGE_PATH)
		
		else:
			material.take_over_path(path)	

	return OK
