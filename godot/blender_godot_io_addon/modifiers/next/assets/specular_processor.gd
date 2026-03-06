@tool
class_name BGIO_Specular_NodeModifier extends BGIO_NodeModifier

func pre_generate(state: GLTFState) -> Error:
	var materials = state.get_materials()
	var json_materials = state.json.get("materials", [])
	
	for i in len(materials):
		var material = materials[i]
		var json_material: Dictionary = json_materials[i]
		var name = json_material["name"]
		
		if "extensions" not in json_material.keys():
			continue

		var extensions: Dictionary = json_material["extensions"]
		if "KHR_materials_specular" not in extensions.keys():
			continue
		
		var specular_properties: Dictionary = extensions["KHR_materials_specular"]
		
		if "specularFactor" in specular_properties:
			if material is BaseMaterial3D:
				material.metallic_specular = specular_properties["specularFactor"]
				
		if "specularColorFactor" in specular_properties:
			var value = specular_properties["specularColorFactor"]
			var text = "%s, %s, %s" % [value[0], value[1], value[2]]
			print("Material %s has specular factor: %s" % [name, text])

	return OK
