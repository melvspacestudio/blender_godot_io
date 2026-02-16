@tool
class_name BlenderGodotIOSettings extends Object

const CONFIG_PATH_SETTING_KEY = "blender_godot_io/configuration_path"

static func init_configuration_path() -> void:
	if not ProjectSettings.get_setting(CONFIG_PATH_SETTING_KEY):
		ProjectSettings.set_setting(CONFIG_PATH_SETTING_KEY, "")
		ProjectSettings.add_property_info({
			"name": CONFIG_PATH_SETTING_KEY,
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_FILE,
			"hint_string": "*.tres,*.res"
		})


static func set_configuration_path(path: String) -> void:
	ProjectSettings.set_setting(CONFIG_PATH_SETTING_KEY, path)
	ProjectSettings.save()


static func get_configuration_path() -> String:
	return ProjectSettings.get_setting(CONFIG_PATH_SETTING_KEY)
