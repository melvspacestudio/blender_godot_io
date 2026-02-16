@tool
class_name BGIO_Processor extends Resource

func _pre_generate(state: GLTFState) -> Error:
	return OK

func _process_scene(state: GLTFState, root: Node) -> Error:
	return OK
