@tool
class_name GGP_Specular_NodeModifier extends GGP_NodeModifier

func pre_generate(state: GLTFState) -> Error:
	var materials: Array[Material] = state.get_materials()
	var json_materials := GGP_AssetProcessor_Utility.get_json_array(state.json, "materials", "GGP_Specular_NodeModifier")

	for i in materials.size():
		var material := materials[i]
		var json_material := GGP_AssetProcessor_Utility.get_json_dictionary(json_materials, i, "materials", "GGP_Specular_NodeModifier")
		if json_material.is_empty():
			continue

		if not json_material.has("extensions"):
			continue

		var extensions_value: Variant = json_material["extensions"]
		if extensions_value is not Dictionary:
			push_warning("GGP_Specular_NodeModifier expected `materials[%d].extensions` to be a Dictionary, got `%s`; skipping specular metadata." % [i, type_string(typeof(extensions_value))])
			continue

		var extensions := extensions_value as Dictionary
		if not extensions.has("KHR_materials_specular"):
			continue

		var specular_value: Variant = extensions["KHR_materials_specular"]
		if specular_value is not Dictionary:
			push_warning("GGP_Specular_NodeModifier expected `materials[%d].extensions.KHR_materials_specular` to be a Dictionary, got `%s`; skipping specular metadata." % [i, type_string(typeof(specular_value))])
			continue

		var specular_properties := specular_value as Dictionary

		if "specularFactor" in specular_properties:
			if material is BaseMaterial3D:
				material.metallic_specular = specular_properties["specularFactor"]

	return OK
