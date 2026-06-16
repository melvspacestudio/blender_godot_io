@tool
@icon("res://addons/godot_gltf_pipeline_addon/logo.svg")
class_name GGP_ImportConfig extends Resource

# --- Static ---

class List:
	var configs: Array[GGP_ImportConfig]
	
	func _init(configs: Array[GGP_ImportConfig]) -> void:
		self.configs = configs

static func get_config(path: String) -> List:
	var configs: Array[GGP_ImportConfig] = []
	var config_paths := _get_config_paths(path)

	# Configs resolve nearest-first. Each folder may contribute only the
	# lexicographically first GGP_ImportConfig resource it contains.
	if config_paths.size() > 1:
		push_warning(
			"Multiple GGP_ImportConfig resources found in %s. Using %s. Candidates: %s"
			% [path, config_paths[0], ", ".join(config_paths)]
		)

	if not config_paths.is_empty():
		var config := ResourceLoader.load(config_paths[0]) as GGP_ImportConfig
		if config:
			configs.append(config)

	if path != "res://":
		configs.append_array(get_config(_get_parent_directory(path)).configs)

	return List.new(configs)


static func _get_config_paths(path: String) -> PackedStringArray:
	var config_paths: PackedStringArray = []
	var resources: PackedStringArray = ResourceLoader.list_directory(path)
	resources.sort()

	for resource_name in resources:
		var resource_path := path.path_join(resource_name)
		if not resource_path.ends_with(".tres") and not resource_path.ends_with(".res"):
			continue
		if not ResourceLoader.exists(resource_path):
			continue

		var resource := ResourceLoader.load(resource_path)
		if resource is GGP_ImportConfig:
			config_paths.append(resource_path)

	config_paths.sort()
	return config_paths


static func _get_parent_directory(path: String) -> String:
	var parts := path.replace("res://", "").split("/", false)
	parts.remove_at(parts.size() - 1)

	if parts.is_empty():
		return "res://"

	return "res://" + "/".join(parts)

# --- Instance ---

@export
var modifiers: Array[GGP_NodeModifier] = []
