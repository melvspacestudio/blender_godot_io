@tool
class_name GGP_Texture_NodeModifier extends GGP_NodeModifier

@export_dir
var texture_dir: String = "assets/textures"

@export
var overwrite_existing: bool = false


func _get_texture_dir() -> String:
	return GGP_AssetProcessor_Utility.resolve_output_dir(resource_path, texture_dir)


func pre_generate(state: GLTFState) -> Error:
	if not texture_dir:
		push_warning("Texture directory is not set for %s" % [self])
		return ERR_SKIP

	var resolved_texture_dir := _get_texture_dir()
	var dir_error := GGP_AssetProcessor_Utility.ensure_output_dir(resolved_texture_dir)
	if dir_error != OK:
		push_warning("Could not create texture directory `%s`: %s. Skipping texture extraction." % [resolved_texture_dir, error_string(dir_error)])
		return ERR_SKIP

	var json := GGP_AssetProcessor_Utility.get_json_array(state.json, "images", "GGP_Texture_NodeModifier")
	var images: Array[Texture2D] = state.get_images()

	for i in images.size():
		var texture: Texture2D = images[i]
		if texture == null:
			push_warning("Skipping null texture at runtime image index %d." % [i])
			continue

		var image := texture.get_image()
		if image == null:
			push_warning("Skipping texture at runtime image index %d because it has no readable Image." % [i])
			continue

		var name := GGP_AssetProcessor_Utility.get_safe_stem_from_json(json, i, "images", "image", "GGP_Texture_NodeModifier")
		var path := resolved_texture_dir.path_join(name + ".png")
		if overwrite_existing or not GGP_AssetProcessor_Utility.resource_file_exists(path):
			var save_error := image.save_png(path)
			if save_error != OK:
				push_warning("Could not save texture `%s`: %s. Skipping runtime image index %d." % [path, error_string(save_error), i])
				continue
			if path.begins_with("res://"):
				ResourceLoader.load(path)

		if GGP_AssetProcessor_Utility.resource_file_exists(path):
			texture.take_over_path(path)

	return OK
