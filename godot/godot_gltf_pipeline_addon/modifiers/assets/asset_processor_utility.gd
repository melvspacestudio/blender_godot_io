@tool
class_name GGP_AssetProcessor_Utility extends Object


static func resolve_output_dir(resource_path: String, output_dir: String) -> String:
	if output_dir.begins_with("res://") or output_dir.begins_with("/") or output_dir.begins_with("user://"):
		return output_dir

	var resource_dir := "res://"
	if resource_path.begins_with("res://"):
		resource_dir = resource_path.get_base_dir()

	return resource_dir.path_join(output_dir)


static func ensure_output_dir(output_dir: String) -> Error:
	if output_dir.is_empty():
		return ERR_INVALID_PARAMETER

	var absolute_dir := _globalize_resource_path(output_dir)
	if DirAccess.dir_exists_absolute(absolute_dir):
		return OK

	return DirAccess.make_dir_recursive_absolute(absolute_dir)


static func resource_file_exists(path: String) -> bool:
	return ResourceLoader.exists(path) or FileAccess.file_exists(path) or FileAccess.file_exists(_globalize_resource_path(path))


static func sanitize_filename_stem(name: String, fallback_prefix: String, index: int) -> String:
	var sanitized := _sanitize_filename_stem(name)
	if sanitized.is_empty():
		return "%s_%d" % [fallback_prefix, index]

	return sanitized


static func get_json_array(json: Dictionary, key: String, processor_name: String) -> Array:
	var value: Variant = json.get(key, [])
	if value is Array:
		return value

	push_warning("%s expected glTF JSON `%s` to be an Array, got `%s`; fallback names will be used." % [processor_name, key, type_string(typeof(value))])
	return []


static func get_safe_stem_from_json(json_entries: Array, index: int, json_key: String, fallback_prefix: String, processor_name: String) -> String:
	var fallback := "%s_%d" % [fallback_prefix, index]
	if index >= json_entries.size():
		push_warning("%s missing glTF JSON `%s[%d]`; using fallback name `%s`." % [processor_name, json_key, index, fallback])
		return fallback

	var entry: Variant = json_entries[index]
	if entry is not Dictionary:
		push_warning("%s expected glTF JSON `%s[%d]` to be a Dictionary, got `%s`; using fallback name `%s`." % [processor_name, json_key, index, type_string(typeof(entry)), fallback])
		return fallback

	var dictionary := entry as Dictionary
	if not dictionary.has("name"):
		push_warning("%s missing `name` in glTF JSON `%s[%d]`; using fallback name `%s`." % [processor_name, json_key, index, fallback])
		return fallback

	var raw_name: Variant = dictionary["name"]
	if raw_name is not String:
		push_warning("%s expected `name` in glTF JSON `%s[%d]` to be a String, got `%s`; using fallback name `%s`." % [processor_name, json_key, index, type_string(typeof(raw_name)), fallback])
		return fallback

	var sanitized := _sanitize_filename_stem(raw_name)
	if sanitized.is_empty():
		push_warning("%s sanitized `name` in glTF JSON `%s[%d]` to an empty filename stem; using fallback name `%s`." % [processor_name, json_key, index, fallback])
		return fallback

	return sanitized


static func get_json_dictionary(json_entries: Array, index: int, json_key: String, processor_name: String) -> Dictionary:
	if index >= json_entries.size():
		push_warning("%s missing glTF JSON `%s[%d]`; skipping metadata for runtime entry %d." % [processor_name, json_key, index, index])
		return {}

	var entry: Variant = json_entries[index]
	if entry is not Dictionary:
		push_warning("%s expected glTF JSON `%s[%d]` to be a Dictionary, got `%s`; skipping metadata for runtime entry %d." % [processor_name, json_key, index, type_string(typeof(entry)), index])
		return {}

	return entry as Dictionary


static func _sanitize_filename_stem(name: String) -> String:
	var sanitized := ""
	var previous_was_underscore := false

	for i in name.length():
		var code := name.unicode_at(i)
		if _is_allowed_filename_code(code):
			var character := name.substr(i, 1)
			if character == "_":
				if previous_was_underscore:
					continue
				previous_was_underscore = true
			else:
				previous_was_underscore = false
			sanitized += character
		elif not previous_was_underscore:
			sanitized += "_"
			previous_was_underscore = true

	while sanitized.begins_with("_"):
		sanitized = sanitized.substr(1)

	while sanitized.ends_with("_"):
		sanitized = sanitized.substr(0, sanitized.length() - 1)

	return sanitized


static func _is_allowed_filename_code(code: int) -> bool:
	return (
		(code >= 48 and code <= 57)
		or (code >= 65 and code <= 90)
		or (code >= 97 and code <= 122)
		or code == 45
		or code == 95
	)


static func _globalize_resource_path(path: String) -> String:
	if path.begins_with("res://") or path.begins_with("user://"):
		return ProjectSettings.globalize_path(path)

	return path
