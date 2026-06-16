extends GdUnitTestSuite

const VALID_MATERIAL_PATH := "res://examples/4_prefabs/assets/materials/_defaultMat.tres"

var _generated_node: Node
var _property_target: ImportedPropertyTarget


class ImportedPropertyTarget:
	extends Resource

	var geometry_nodes: bool = false
	var label: String = "initial"


func before_test() -> void:
	_generated_node = null
	_property_target = null


func after_test() -> void:
	_generated_node = null
	_property_target = null


func test_blacklisted_class_returns_original_without_warning() -> void:
	await assert_error(Callable(self, "_generate_blacklisted_node")).is_success()

	assert_bool(_generated_node == null).is_true()


func test_explicit_missing_class_warns_and_returns_original() -> void:
	await assert_error(Callable(self, "_generate_missing_class_node")).is_push_warning(any_string())

	assert_bool(_generated_node == null).is_true()


func test_non_node_class_warns_and_returns_original() -> void:
	await assert_error(Callable(self, "_generate_resource_class_node")).is_push_warning(any_string())

	assert_bool(_generated_node == null).is_true()


func test_reserved_and_unknown_properties_are_skipped_without_warning() -> void:
	await assert_error(Callable(self, "_apply_reserved_and_unknown_properties")).is_success()

	assert_bool(_property_target.geometry_nodes).is_false()
	assert_str(_property_target.label).is_equal("initial")


func test_valid_property_application_converts_vectors_and_loads_resources() -> void:
	await assert_error(Callable(self, "_generate_valid_property_node")).is_success()

	var node := _generated_node as Node3D
	assert_bool(node.visible).is_false()
	assert_str(str(node.position)).is_equal(str(Vector3(1.0, 2.0, 3.0)))

	var generated_mesh := _generate_node("MeshInstance3D", {"class_name": "MeshInstance3D", "material_override": VALID_MATERIAL_PATH})
	var mesh_node := generated_mesh as MeshInstance3D
	assert_bool(mesh_node.material_override is Material).is_true()

	var nested_result := GGP_NodeUtility.apply_imported_property(mesh_node, "material_override.resource_name", "ImportedMaterial")
	assert_str(nested_result.get("status", "")).is_equal(GGP_NodeUtility.IMPORTED_PROPERTY_APPLIED)
	assert_str(mesh_node.material_override.resource_name).is_equal("ImportedMaterial")


func test_failed_property_assignment_warns_and_keeps_other_properties() -> void:
	await assert_error(Callable(self, "_generate_invalid_property_node")).is_push_warning(any_string())

	var node := _generated_node as Node3D
	assert_bool(node.visible).is_false()
	assert_str(str(node.position)).is_equal(str(Vector3.ZERO))


func test_invalid_resource_reference_warns_and_skips_only_that_property() -> void:
	await assert_error(Callable(self, "_generate_invalid_resource_property_node")).is_push_warning(any_string())

	var mesh_node := _generated_node as MeshInstance3D
	assert_bool(mesh_node.visible).is_false()
	assert_bool(mesh_node.material_override == null).is_true()


func test_mesh_backed_class_preserves_importer_mesh_child() -> void:
	var state := GLTFState.new()
	var gltf_mesh := GLTFMesh.new()
	gltf_mesh.mesh = ImporterMesh.new()
	state.set_meshes([gltf_mesh])
	var gltf_node := _gltf_node("GeneratedMeshNode", {"class_name": "Node3D"}, 0)

	_generated_node = _auto_free_node(GGP_ClassNodeModifier.new().generate_node(state, gltf_node, null, null))

	assert_bool(_generated_node is Node3D).is_true()
	assert_int(_generated_node.get_child_count()).is_equal(1)
	assert_str(_generated_node.get_child(0).name).is_equal("MeshInstance3D")
	assert_bool(_generated_node.get_child(0) is ImporterMeshInstance3D).is_true()


func _generate_blacklisted_node() -> void:
	var modifier := GGP_ClassNodeModifier.new()
	modifier.blacklist = ["Node3D"]
	_generated_node = modifier.generate_node(GLTFState.new(), _gltf_node("GeneratedNode", {"class_name": "Node3D"}), null, null)


func _generate_missing_class_node() -> void:
	_generated_node = _generate_node("GeneratedNode", {"class_name": "DefinitelyMissingClass"})


func _generate_resource_class_node() -> void:
	_generated_node = _generate_node("GeneratedResource", {"class_name": "Resource"})


func _apply_reserved_and_unknown_properties() -> void:
	_property_target = ImportedPropertyTarget.new()
	var reserved := GGP_NodeUtility.apply_imported_property(_property_target, "geometry_nodes", true, ["geometry_nodes"])
	var unknown := GGP_NodeUtility.apply_imported_property(_property_target, "not_a_property", "value", ["geometry_nodes"])

	assert_str(reserved.get("status", "")).is_equal(GGP_NodeUtility.IMPORTED_PROPERTY_SKIPPED_RESERVED)
	assert_str(unknown.get("status", "")).is_equal(GGP_NodeUtility.IMPORTED_PROPERTY_SKIPPED_UNKNOWN)


func _generate_valid_property_node() -> void:
	_generated_node = _generate_node(
		"GeneratedNode",
		{
			"class_name": "Node3D",
			"visible": false,
			"position": [1.0, 2.0, 3.0],
		}
	)


func _generate_invalid_property_node() -> void:
	_generated_node = _generate_node(
		"GeneratedNode",
		{
			"class_name": "Node3D",
			"visible": false,
			"position": ["invalid", "invalid", "invalid"],
		}
	)


func _generate_invalid_resource_property_node() -> void:
	_generated_node = _generate_node(
		"GeneratedMeshInstance",
		{
			"class_name": "MeshInstance3D",
			"visible": false,
			"material_override": "res://tests/classes/fixtures/missing_material.tres",
		}
	)


func _generate_node(original_name: String, extras: Dictionary) -> Node:
	return _auto_free_node(GGP_ClassNodeModifier.new().generate_node(GLTFState.new(), _gltf_node(original_name, extras), null, null))


func _auto_free_node(node: Node) -> Node:
	if node:
		return auto_free(node)
	return node


func _gltf_node(original_name: String, extras: Dictionary, mesh_index: int = -1) -> GLTFNode:
	var gltf_node := GLTFNode.new()
	gltf_node.original_name = original_name
	gltf_node.resource_name = original_name
	gltf_node.mesh = mesh_index
	gltf_node.set_meta("extras", extras)
	return gltf_node
