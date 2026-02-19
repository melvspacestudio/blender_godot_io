@tool
class_name BGIO_LightmapProcessor extends BGIO_Processor

func _process_scene(state: GLTFState, root: Node) -> Error:
	#print(JSON.stringify(state.json, "  "))
	return OK
