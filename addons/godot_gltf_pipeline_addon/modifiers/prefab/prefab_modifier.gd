@tool
class_name GGP_PrefabModifier extends GGP_NodeModifier

const ERROR_CONTEXT_META := "prefab_error"
const ERROR_PLACEHOLDER_SCENE_PATH := "res://addons/godot_gltf_pipeline_addon/scenes/prefab_error_placeholder.tscn"

@export_dir
var prefab_dir: String = "prefabs"

@export
var extensions: Array[String] = [".tscn", ".scn", ".glb", ".gltf"]

func process_node(state: GLTFState, gltf_node: GLTFNode, json: Dictionary, node: Node) -> Node:
	var name = _get_name_from_node(node)
	if name.begins_with("$"):
		var dir = GGP_Path.resolve_at(self, prefab_dir)
		var prefab_path = dir.path_join(name.substr(1))
		var extras: Dictionary = node.get_meta("extras") if node.has_meta("extras") else {}
		var resolution := _resolve_prefab(prefab_path)

		if extras.get("geometry_nodes", false):
			for child in node.get_children():
				var child_prefab_node := _instantiate_prefab_or_error(resolution, name, child)
				GGP_NodeUtility.replace(child, child_prefab_node, extras)

			return node

		return _instantiate_prefab_or_error(resolution, name, node)

	return node


func _resolve_prefab(prefab_path: String) -> Dictionary:
	var attempted_candidate_paths: Array[String] = []
	var invalid_candidate_paths: Array[String] = []
	var skipped_extensions: Array[String] = []

	for extension in extensions:
		var normalized_extension := extension.strip_edges()
		if normalized_extension.is_empty() or normalized_extension.contains("/") or normalized_extension.contains("\\"):
			skipped_extensions.append(extension)
			continue

		var candidate_path := prefab_path + normalized_extension
		attempted_candidate_paths.append(candidate_path)
		if not ResourceLoader.exists(candidate_path):
			continue

		var loaded_prefab: Resource = ResourceLoader.load(candidate_path)
		if loaded_prefab is PackedScene:
			return {
				"prefab": loaded_prefab,
				"resolved_base_path": prefab_path,
				"attempted_candidate_paths": attempted_candidate_paths,
				"invalid_candidate_paths": invalid_candidate_paths,
				"skipped_extensions": skipped_extensions,
				"failure_reason": "",
			}

		invalid_candidate_paths.append(candidate_path)

	var failure_reason := "Prefab resource not found."
	if attempted_candidate_paths.is_empty():
		failure_reason = "No valid prefab extensions are configured."
	elif not invalid_candidate_paths.is_empty():
		failure_reason = "No candidate resource loaded as PackedScene."

	return {
		"prefab": null,
		"resolved_base_path": prefab_path,
		"attempted_candidate_paths": attempted_candidate_paths,
		"invalid_candidate_paths": invalid_candidate_paths,
		"skipped_extensions": skipped_extensions,
		"failure_reason": failure_reason,
	}


func _instantiate_prefab_or_error(resolution: Dictionary, marker_name: String, target_node: Node) -> Node:
	var prefab := resolution.get("prefab") as PackedScene
	if prefab:
		var scene_state: SceneState = prefab.get_state()
		if scene_state and scene_state.get_node_count() > 0:
			var prefab_node = prefab.instantiate()
			if prefab_node is Node:
				return prefab_node

		var failed_resolution := resolution.duplicate(true)
		failed_resolution["failure_reason"] = "PackedScene.instantiate() did not produce a Node."
		return _instantiate_error_placeholder(failed_resolution, marker_name, target_node)

	return _instantiate_error_placeholder(resolution, marker_name, target_node)


func _instantiate_error_placeholder(resolution: Dictionary, marker_name: String, target_node: Node) -> Node:
	var placeholder_scene: Resource = ResourceLoader.load(ERROR_PLACEHOLDER_SCENE_PATH)
	var placeholder: Node = null
	if placeholder_scene is PackedScene:
		var placeholder_instance = placeholder_scene.instantiate()
		if placeholder_instance is Node:
			placeholder = placeholder_instance

	if not placeholder:
		push_warning("Prefab error placeholder scene could not be loaded at %s." % ERROR_PLACEHOLDER_SCENE_PATH)
		placeholder = Node3D.new() if target_node is Node3D else Node.new()

	var context := {
		"marker_name": marker_name,
		"target_node_name": target_node.name,
		"resolved_base_path": resolution.get("resolved_base_path", ""),
		"attempted_candidate_paths": resolution.get("attempted_candidate_paths", []),
		"invalid_candidate_paths": resolution.get("invalid_candidate_paths", []),
		"skipped_extensions": resolution.get("skipped_extensions", []),
		"failure_reason": resolution.get("failure_reason", "Prefab replacement failed."),
	}

	placeholder.set_meta(ERROR_CONTEXT_META, context)
	_apply_error_context_to_placeholder(placeholder, context)

	if placeholder is Node3D and target_node is Node3D:
		placeholder.transform = target_node.transform

	return placeholder


func _apply_error_context_to_placeholder(placeholder: Node, context: Dictionary) -> void:
	var label := placeholder.find_child("DebugLabel", true, false)
	if label is Label3D:
		label.text = _format_error_context(context)


func _format_error_context(context: Dictionary) -> String:
	var attempted_paths := PackedStringArray()
	for path in context.get("attempted_candidate_paths", []):
		attempted_paths.append(str(path))

	var attempts := "(none)"
	if not attempted_paths.is_empty():
		attempts = "\n".join(attempted_paths)

	return "Prefab error\nMarker: %s\nBase: %s\nReason: %s\nAttempts:\n%s" % [
		context.get("marker_name", ""),
		context.get("resolved_base_path", ""),
		context.get("failure_reason", ""),
		attempts,
	]
