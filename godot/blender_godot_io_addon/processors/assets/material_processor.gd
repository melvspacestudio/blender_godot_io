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
	
	var json = state.json["images"]
	var images = state.get_images()
	for i in len(images):
		var name = json[i]["name"]
		var texture: Texture2D = images[i]
		var image := texture.get_image()
		
		var path = _get_material_dir().path_join(name + ".png")
		if not ResourceLoader.exists(path):
			image.save_png(path)
			load(path)

		texture.take_over_path(path)
		
	return OK
