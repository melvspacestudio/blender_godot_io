extends GdUnitTestSuite

const PREFAB_DIR := "res://tests/prefab/fixtures/prefabs"
const ERROR_CONTEXT_META := "prefab_error"


func test_successful_normal_replacement_preserves_extension_replace_behavior() -> void:
	var marker_transform := Transform3D(Basis.from_euler(Vector3(0.25, 0.5, 0.75)).scaled(Vector3(2.0, 3.0, 4.0)), Vector3(1.0, 2.0, 3.0))
	var marker := _marker("$TestPrefab", marker_transform, {"source": "marker"})
	var marker_child := Node3D.new()
	marker_child.name = "MarkerChild"
	marker.add_child(marker_child)
	var root := _root_with_marker(marker)
	marker_child.owner = root
	var modifier := _modifier([".tscn"])

	var prefab_node := modifier.process_node(GLTFState.new(), GLTFNode.new(), {}, marker)
	GGP_NodeUtility.replace(marker, prefab_node)

	assert_bool(prefab_node.has_meta(ERROR_CONTEXT_META)).is_false()
	assert_str(prefab_node.name).is_equal("$TestPrefab")
	assert_bool(prefab_node.owner == root).is_true()
	assert_str(str(prefab_node.transform)).is_equal(str(marker_transform))
	assert_str(str(prefab_node.get_meta("extras"))).is_equal(str({"source": "marker"}))
	assert_bool(prefab_node.find_child("MarkerChild", true, false) == null).is_true()
	assert_bool(prefab_node.find_child("PrefabVisual", true, false) != null).is_true()

	root.free()


func test_geometry_nodes_replaces_each_child_with_fresh_prefab_instance() -> void:
	var marker := _marker("$TestPrefab", Transform3D.IDENTITY, {"geometry_nodes": true})
	var child_a := _marker("ChildA", Transform3D(Basis.IDENTITY, Vector3(1.0, 0.0, 0.0)), {})
	var child_b := _marker("ChildB", Transform3D(Basis.IDENTITY, Vector3(2.0, 0.0, 0.0)), {})
	marker.add_child(child_a)
	marker.add_child(child_b)
	var root := _root_with_marker(marker)
	child_a.owner = root
	child_b.owner = root
	var modifier := _modifier([".tscn"])

	var result := modifier.process_node(GLTFState.new(), GLTFNode.new(), {}, marker)
	var active_children := _active_children(marker)

	assert_bool(result == marker).is_true()
	assert_bool(child_a.is_queued_for_deletion()).is_true()
	assert_bool(child_b.is_queued_for_deletion()).is_true()
	assert_int(active_children.size()).is_equal(2)
	assert_str(active_children[0].name).is_equal("ChildA")
	assert_str(active_children[1].name).is_equal("ChildB")
	assert_bool(active_children[0] != active_children[1]).is_true()
	assert_bool(active_children[0].find_child("PrefabVisual", true, false) != null).is_true()
	assert_bool(active_children[1].find_child("PrefabVisual", true, false) != null).is_true()

	root.free()


func test_extensions_keep_configured_order_and_continue_after_invalid_candidate() -> void:
	var modifier := _modifier(["", "/", ".tres", ".tscn"])
	var resolution := modifier._resolve_prefab(PREFAB_DIR.path_join("FallbackOrder"))

	assert_bool(resolution.get("prefab") is PackedScene).is_true()
	assert_array(resolution.get("skipped_extensions")).contains_exactly("", "/")
	assert_array(resolution.get("attempted_candidate_paths")).contains_exactly(
		PREFAB_DIR.path_join("FallbackOrder.tres"),
		PREFAB_DIR.path_join("FallbackOrder.tscn")
	)
	assert_array(resolution.get("invalid_candidate_paths")).contains_exactly(PREFAB_DIR.path_join("FallbackOrder.tres"))

	var marker := _marker("$FallbackOrder", Transform3D.IDENTITY, {})
	var root := _root_with_marker(marker)
	var prefab_node := modifier.process_node(GLTFState.new(), GLTFNode.new(), {}, marker)
	GGP_NodeUtility.replace(marker, prefab_node)

	assert_bool(prefab_node.has_meta(ERROR_CONTEXT_META)).is_false()
	assert_bool(prefab_node.find_child("LoadedAfterInvalidCandidate", true, false) != null).is_true()

	root.free()


func test_missing_prefab_returns_error_placeholder_with_context_and_transform() -> void:
	var marker_transform := Transform3D(Basis.IDENTITY.scaled(Vector3(1.5, 2.0, 2.5)), Vector3(3.0, 4.0, 5.0))
	var marker := _marker("$MissingPrefab", marker_transform, {"source": "missing"})
	var root := _root_with_marker(marker)
	var modifier := _modifier([".tscn"])

	var placeholder := modifier.process_node(GLTFState.new(), GLTFNode.new(), {}, marker)
	GGP_NodeUtility.replace(marker, placeholder)
	var context: Dictionary = placeholder.get_meta(ERROR_CONTEXT_META)

	assert_str(placeholder.name).is_equal("$MissingPrefab")
	assert_str(str(placeholder.transform)).is_equal(str(marker_transform))
	assert_str(context.get("marker_name", "")).is_equal("$MissingPrefab")
	assert_str(context.get("target_node_name", "")).is_equal("$MissingPrefab")
	assert_str(context.get("resolved_base_path", "")).is_equal(PREFAB_DIR.path_join("MissingPrefab"))
	assert_array(context.get("attempted_candidate_paths")).contains_exactly(PREFAB_DIR.path_join("MissingPrefab.tscn"))
	assert_bool(str(context.get("failure_reason", "")).contains("not found")).is_true()
	assert_bool(placeholder.find_child("DebugLabel", true, false) != null).is_true()

	root.free()


func test_geometry_nodes_missing_prefab_replaces_each_child_with_error_placeholder() -> void:
	var marker := _marker("$MissingPrefab", Transform3D.IDENTITY, {"geometry_nodes": true})
	var child_a_transform := Transform3D(Basis.IDENTITY.scaled(Vector3(2.0, 2.0, 2.0)), Vector3(1.0, 2.0, 3.0))
	var child_b_transform := Transform3D(Basis.IDENTITY.scaled(Vector3(3.0, 3.0, 3.0)), Vector3(4.0, 5.0, 6.0))
	var child_a := _marker("ChildA", child_a_transform, {})
	var child_b := _marker("ChildB", child_b_transform, {})
	marker.add_child(child_a)
	marker.add_child(child_b)
	var root := _root_with_marker(marker)
	child_a.owner = root
	child_b.owner = root
	var modifier := _modifier([".tscn"])

	assert_bool(modifier.process_node(GLTFState.new(), GLTFNode.new(), {}, marker) == marker).is_true()
	var active_children := _active_children(marker)
	var context_a: Dictionary = active_children[0].get_meta(ERROR_CONTEXT_META)
	var context_b: Dictionary = active_children[1].get_meta(ERROR_CONTEXT_META)

	assert_int(active_children.size()).is_equal(2)
	assert_str(str(active_children[0].transform)).is_equal(str(child_a_transform))
	assert_str(str(active_children[1].transform)).is_equal(str(child_b_transform))
	assert_bool(active_children[0] != active_children[1]).is_true()
	assert_str(context_a.get("marker_name", "")).is_equal("$MissingPrefab")
	assert_str(context_a.get("target_node_name", "")).is_equal("ChildA")
	assert_str(context_b.get("marker_name", "")).is_equal("$MissingPrefab")
	assert_str(context_b.get("target_node_name", "")).is_equal("ChildB")

	root.free()


func test_empty_packed_scene_instantiation_falls_back_to_error_placeholder() -> void:
	var marker_transform := Transform3D(Basis.IDENTITY, Vector3(7.0, 8.0, 9.0))
	var marker := _marker("$BrokenPrefab", marker_transform, {})
	var root := _root_with_marker(marker)
	var modifier := _modifier([".tscn"])
	var resolution := {
		"prefab": PackedScene.new(),
		"resolved_base_path": PREFAB_DIR.path_join("BrokenPrefab"),
		"attempted_candidate_paths": [PREFAB_DIR.path_join("BrokenPrefab.tscn")],
		"failure_reason": "",
	}

	var placeholder := modifier._instantiate_prefab_or_error(resolution, "$BrokenPrefab", marker)
	var context: Dictionary = placeholder.get_meta(ERROR_CONTEXT_META)

	assert_str(str(placeholder.transform)).is_equal(str(marker_transform))
	assert_bool(str(context.get("failure_reason", "")).contains("instantiate")).is_true()

	placeholder.free()
	root.free()


func _modifier(prefab_extensions: Array[String]) -> GGP_PrefabModifier:
	var modifier := GGP_PrefabModifier.new()
	modifier.prefab_dir = PREFAB_DIR
	modifier.extensions = prefab_extensions
	return modifier


func _marker(marker_name: String, marker_transform: Transform3D, extras: Dictionary) -> Node3D:
	var marker := Node3D.new()
	marker.name = marker_name
	marker.transform = marker_transform
	marker.set_meta("extras", extras)
	return marker


func _root_with_marker(marker: Node3D) -> Node3D:
	var root := Node3D.new()
	root.name = "Root"
	var parent := Node3D.new()
	parent.name = "Parent"
	root.add_child(parent)
	parent.owner = root
	parent.add_child(marker)
	marker.owner = root
	return root


func _active_children(node: Node) -> Array[Node]:
	var active: Array[Node] = []
	for child in node.get_children():
		if not child.is_queued_for_deletion():
			active.append(child)
	return active
