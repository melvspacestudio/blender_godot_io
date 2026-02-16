class_name BlenderGodotIO_GLTF_Extension extends GLTFDocumentExtension

static var TAG:
	get: return "BlenderGodotIO_GLTF_Extension"
	
func _import_preflight(state: GLTFState, extensions: PackedStringArray) -> Error:
	var list := BGIO_ImportConfig.get_config(state.base_path)
	if list.configs.is_empty():
		return ERR_SKIP
	
	return OK
	
func _import_pre_generate(state: GLTFState) -> Error:
	var list := BGIO_ImportConfig.get_config(state.base_path)
	var completed_processors: Array[String] = []
	
	for config in list.configs:
		for processor in config.processors:
			if processor.get_class() in completed_processors:
				print("Skipping %s from %s because it was already ran", processor.get_class(), config.resource_path)
				continue
				
			processor._pre_generate(state)
			completed_processors.append(processor.get_class())
	
	return OK


func _generate_scene_node(state: GLTFState, gltf_node: GLTFNode, scene_parent: Node) -> Node3D:
	var list := BGIO_ImportConfig.get_config(state.base_path)
	var completed_modifiers: Array[String] = []
	var node: Node = null
	
	for config in list.configs:
		for modifier in config.modifiers:
			if modifier.get_class() in completed_modifiers:
				print("Skipping %s from %s because it was already ran", modifier.get_class(), config.resource_path)
				continue
				
			node = modifier._generate_node(state, gltf_node, scene_parent, node)
			completed_modifiers.append(modifier.get_class())
			
	return node

func _import_node(state: GLTFState, gltf_node: GLTFNode, json: Dictionary, node: Node) -> Error:
	var list := BGIO_ImportConfig.get_config(state.base_path)
	var completed_modifiers: Array[String] = []
	
	for config in list.configs:
		for modifier in config.modifiers:
			if modifier.get_class() in completed_modifiers:
				print("Skipping %s from %s because it was already ran", modifier.get_class(), config.resource_path)
				continue
				
			node = modifier._process_node(node)
			completed_modifiers.append(modifier.get_class())
	
	return OK

func _import_post(state: GLTFState, root: Node) -> Error:
	var list := BGIO_ImportConfig.get_config(state.base_path)
	var completed_processors: Array[String] = []
	
	for config in list.configs:
		for processor in config.processors:
			if processor.get_class() in completed_processors:
				print("Skipping %s from %s because it was already ran", processor.get_class(), config.resource_path)
				continue
				
			processor._process_scene(state, root)
			completed_processors.append(processor.get_class())
	
	return OK
