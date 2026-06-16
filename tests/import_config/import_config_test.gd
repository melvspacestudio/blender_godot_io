extends GdUnitTestSuite

const ORDER_CHILD_PATH := "res://tests/import_config/fixtures/order/child"
const DUPLICATE_PATH := "res://tests/import_config/fixtures/duplicates/asset"
const DEDUP_CHILD_PATH := "res://tests/import_config/fixtures/dedup/child"

var _captured_config: GGP_ImportConfig.List


func before_test() -> void:
	_captured_config = null
	GGP_TestRecordingModifier.reset()


func test_get_config_resolves_nearest_first_and_ignores_non_config_resources() -> void:
	var paths := _config_paths(GGP_ImportConfig.get_config(ORDER_CHILD_PATH))

	assert_int(paths.size()).is_greater_equal(2)
	assert_str(paths[0]).is_equal("res://tests/import_config/fixtures/order/child/import_config.tres")
	assert_str(paths[1]).is_equal("res://tests/import_config/fixtures/order/import_config.tres")
	assert_array(paths).not_contains("res://tests/import_config/fixtures/order/child/not_import_config.tres")


func test_multiple_configs_warns_and_selects_lexicographic_first() -> void:
	var expected_warning := (
		"Multiple GGP_ImportConfig resources found in %s. Using %s. Candidates: %s"
		% [
			DUPLICATE_PATH,
			"res://tests/import_config/fixtures/duplicates/asset/a_config.tres",
			(
				"res://tests/import_config/fixtures/duplicates/asset/a_config.tres, "
				+ "res://tests/import_config/fixtures/duplicates/asset/b_config.tres"
			)
		]
	)

	await assert_error(Callable(self, "_capture_duplicate_config")).is_push_warning(expected_warning)

	var paths := _config_paths(_captured_config)
	assert_str(paths[0]).is_equal("res://tests/import_config/fixtures/duplicates/asset/a_config.tres")


func test_gltf_extension_deduplicates_modifier_scripts_nearest_first() -> void:
	var state := GLTFState.new()
	state.base_path = DEDUP_CHILD_PATH

	var extension := GGP_GLTF_Extension.new()
	assert_int(extension._import_pre_generate(state)).is_equal(OK)

	assert_array(GGP_TestRecordingModifier.events).contains_exactly("local")


func _config_paths(list: GGP_ImportConfig.List) -> Array[String]:
	var paths: Array[String] = []
	for config in list.configs:
		paths.append(config.resource_path)

	return paths


func _capture_duplicate_config() -> void:
	_captured_config = GGP_ImportConfig.get_config(DUPLICATE_PATH)
