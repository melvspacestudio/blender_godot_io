@tool
class_name BGIO_DumpGLTF_NodeModifier extends BGIO_NodeModifier

@export_enum("nodes", "meshes", "materials", "textures", "other", "all")
var target: String = "nodes"


func pre_generate(state: GLTFState) -> Error:
	if target == "all":
		print(JSON.stringify(state.json, "  "))
		return OK
		
	if target == "other":
		var json = {}
		for key in state.json.keys():
			if key not in ["nodes", "meshes", "materials", "textures"]:
				json[key] = state.json[key]

		print(JSON.stringify(json, "  "))
		return OK
		
	print(JSON.stringify(state.json[target], "  "))
	return OK
