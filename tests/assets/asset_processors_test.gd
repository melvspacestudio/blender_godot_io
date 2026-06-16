extends GdUnitTestSuite


func test_sanitize_filename_stem_allows_only_safe_ascii_and_uses_fallbacks() -> void:
	assert_str(GGP_AssetProcessor_Utility.sanitize_filename_stem("Safe_Name-09", "image", 0)).is_equal("Safe_Name-09")
	assert_str(GGP_AssetProcessor_Utility.sanitize_filename_stem("../folder/texture.name", "image", 1)).is_equal("folder_texture_name")
	assert_str(GGP_AssetProcessor_Utility.sanitize_filename_stem("white space", "image", 2)).is_equal("white_space")
	assert_str(GGP_AssetProcessor_Utility.sanitize_filename_stem("..", "image", 3)).is_equal("image_3")
	assert_str(GGP_AssetProcessor_Utility.sanitize_filename_stem("éあ", "image", 4)).is_equal("image_4")
	assert_str(GGP_AssetProcessor_Utility.sanitize_filename_stem("a///...   b", "image", 5)).is_equal("a_b")


func test_texture_processor_uses_fallback_names_for_missing_json_entries() -> void:
	var output_dir := create_temp_dir("texture_fallbacks")
	var state := _state_with_images({}, [_texture(Color.RED), _texture(Color.BLUE)])
	var processor := GGP_Texture_NodeModifier.new()
	processor.texture_dir = output_dir

	assert_int(processor.pre_generate(state)).is_equal(OK)

	assert_bool(FileAccess.file_exists(output_dir.path_join("image_0.png"))).is_true()
	assert_bool(FileAccess.file_exists(output_dir.path_join("image_1.png"))).is_true()
	assert_str(state.get_images()[0].resource_path).is_not_empty()
	assert_str(state.get_images()[1].resource_path).is_not_empty()


func test_material_processor_uses_fallback_names_for_missing_json_entries() -> void:
	var output_dir := create_temp_dir("material_fallbacks")
	var materials: Array[Material] = [_material(Color.RED), _material(Color.BLUE)]
	var state := _state_with_materials({"materials": [{}]}, materials)
	var processor := GGP_Material_NodeModifier.new()
	processor.material_dir = output_dir

	assert_int(processor.pre_generate(state)).is_equal(OK)

	assert_bool(FileAccess.file_exists(output_dir.path_join("material_0.tres"))).is_true()
	assert_bool(FileAccess.file_exists(output_dir.path_join("material_1.tres"))).is_true()
	assert_str(materials[0].get_meta("material_path", "")).is_equal(output_dir.path_join("material_0.tres"))
	assert_str(materials[1].get_meta("material_path", "")).is_equal(output_dir.path_join("material_1.tres"))


func test_duplicate_texture_names_reuse_path_without_overwrite_by_default() -> void:
	var output_dir := create_temp_dir("texture_duplicate_no_overwrite")
	var state := _state_with_images(
		{"images": [{"name": "shared"}, {"name": "shared"}]},
		[_texture(Color.RED), _texture(Color.BLUE)]
	)
	var processor := GGP_Texture_NodeModifier.new()
	processor.texture_dir = output_dir

	assert_int(processor.pre_generate(state)).is_equal(OK)

	var path := output_dir.path_join("shared.png")
	assert_bool(FileAccess.file_exists(path)).is_true()
	assert_str(_loaded_png_color(path)).is_equal(Color.RED.to_html(false))


func test_duplicate_texture_names_overwrite_in_runtime_order_when_enabled() -> void:
	var output_dir := create_temp_dir("texture_duplicate_overwrite")
	var state := _state_with_images(
		{"images": [{"name": "shared"}, {"name": "shared"}]},
		[_texture(Color.RED), _texture(Color.BLUE)]
	)
	var processor := GGP_Texture_NodeModifier.new()
	processor.texture_dir = output_dir
	processor.overwrite_existing = true

	assert_int(processor.pre_generate(state)).is_equal(OK)

	var path := output_dir.path_join("shared.png")
	assert_bool(FileAccess.file_exists(path)).is_true()
	assert_str(_loaded_png_color(path)).is_equal(Color.BLUE.to_html(false))


func test_duplicate_material_names_reuse_path() -> void:
	var output_dir := create_temp_dir("material_duplicate")
	var materials: Array[Material] = [_material(Color.RED), _material(Color.BLUE)]
	var state := _state_with_materials(
		{"materials": [{"name": "shared"}, {"name": "shared"}]},
		materials
	)
	var processor := GGP_Material_NodeModifier.new()
	processor.material_dir = output_dir

	assert_int(processor.pre_generate(state)).is_equal(OK)

	var path := output_dir.path_join("shared.tres")
	assert_str(materials[0].get_meta("material_path", "")).is_equal(path)
	assert_str(materials[1].get_meta("material_path", "")).is_equal(path)


func test_processors_warn_and_skip_when_output_directory_cannot_be_created() -> void:
	var processor := GGP_Material_NodeModifier.new()
	processor.material_dir = "/proc/godot_gltf_pipeline_denied/materials"
	var material := _material(Color.RED)
	var state := _state_with_materials({"materials": [{"name": "blocked"}]}, [material])

	await assert_error(Callable(processor, "pre_generate").bind(state)).is_push_warning(any_string())

	assert_bool(material.has_meta("material_path")).is_false()


func test_specular_processor_handles_material_json_mismatch_without_crashing() -> void:
	var material := _material(Color.WHITE)
	var state := _state_with_materials({}, [material])
	var processor := GGP_Specular_NodeModifier.new()

	await assert_error(Callable(processor, "pre_generate").bind(state)).is_push_warning(any_string())


func test_specular_processor_applies_factor_without_normal_path_warning() -> void:
	var material := _material(Color.WHITE)
	var state := _state_with_materials(
		{
			"materials": [
				{
					"name": "specular",
					"extensions": {
						"KHR_materials_specular": {
							"specularFactor": 0.25,
							"specularColorFactor": [1.0, 0.5, 0.25]
						}
					}
				}
			]
		},
		[material]
	)
	var processor := GGP_Specular_NodeModifier.new()

	await assert_error(Callable(processor, "pre_generate").bind(state)).is_success()

	assert_str(str(material.metallic_specular)).is_equal(str(0.25))


func _state_with_images(json: Dictionary, images: Array[Texture2D]) -> GLTFState:
	var state := GLTFState.new()
	state.json = json
	state.set_images(images)
	return state


func _state_with_materials(json: Dictionary, materials: Array[Material]) -> GLTFState:
	var state := GLTFState.new()
	state.json = json
	state.set_materials(materials)
	return state


func _texture(color: Color) -> Texture2D:
	var image := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	image.fill(color)
	return ImageTexture.create_from_image(image)


func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	return material


func _loaded_png_color(path: String) -> String:
	var image := Image.new()
	assert_int(image.load(path)).is_equal(OK)
	return image.get_pixel(0, 0).to_html(false)
