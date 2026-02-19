class_name BGIO_ImportConfig extends Resource

# --- Static ---

class List:
	var configs: Array[BGIO_ImportConfig]
	
	func _init(configs: Array[BGIO_ImportConfig]) -> void:
		self.configs = configs

static func get_config(path: String) -> List:
	var configs: Array[BGIO_ImportConfig] = []
	var resources: PackedStringArray = ResourceLoader.list_directory(path)

	for resource_name in resources:
		var resource_path = path + "/" + resource_name
		if not resource_path.ends_with(".tres") and not resource_path.ends_with(".res"):
			continue
		if not ResourceLoader.exists(resource_path):
			continue

		var resource = ResourceLoader.load(resource_path)
		if resource is BGIO_ImportConfig:
			configs.append(resource)

	if path != "res://":
		var parts = path.replace("res://", "").split("/")
		parts.remove_at(parts.size() - 1)
		
		var parent_directory = "res://" + "/".join(parts)
		configs.append_array(get_config(parent_directory).configs)

	return List.new(configs)

# --- Instance ---

@export
var processors: Array[BGIO_Processor]

@export
var modifiers: Array[BGIO_NodeModifier]
