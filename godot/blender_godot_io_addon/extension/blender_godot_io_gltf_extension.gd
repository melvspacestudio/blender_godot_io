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
	var completed_modifiers: Array[String] = []
	
	for config in list.configs:
		for modifier in config.modifiers:
			if not modifier.enabled:
				continue

			if modifier.get_script().get_global_name() in completed_modifiers:
				print("Skipping %s from %s because it was already ran" % [modifier.get_script().get_global_name(), config.resource_path])
				continue
				
			modifier.pre_generate(state)
			completed_modifiers.append(modifier.get_script().get_global_name())
	
	return OK


func _generate_scene_node(state: GLTFState, gltf_node: GLTFNode, scene_parent: Node) -> Node3D:
	var list := BGIO_ImportConfig.get_config(state.base_path)
	var completed_modifiers: Array[String] = []
	var node: Node = null
	
	for config in list.configs:
		for modifier in config.modifiers:
			if not modifier.enabled:
				continue
				
			if modifier.get_script().get_global_name() in completed_modifiers:
				print("Skipping %s from %s because it was already ran" % [modifier.get_script().get_global_name(), config.resource_path])
				continue
				
			node = modifier.generate_node(state, gltf_node, scene_parent, node)
			completed_modifiers.append(modifier.get_script().get_global_name())
			
	return node
	
func _import_node(state: GLTFState, gltf_node: GLTFNode, json: Dictionary, node: Node) -> Error:
	var list := BGIO_ImportConfig.get_config(state.base_path)
	var completed_modifiers: Array[String] = []
	
	for config in list.configs:
		for modifier in config.modifiers:
			if not modifier.enabled:
				continue

			if modifier.get_script().get_global_name() in completed_modifiers:
				print("Skipping %s from %s because it was already ran" % [modifier.get_script().get_global_name(), config.resource_path])
				continue
			
			var new_node = modifier.process_node(state, gltf_node, json, node)
			if not is_instance_valid(new_node):
				break

			if node != new_node:
				BlenderNodes.replace(node, new_node)
				node = new_node
			
			completed_modifiers.append(modifier.get_script().get_global_name())
	
	return OK

func _import_post(state: GLTFState, root: Node) -> Error:
	var list := BGIO_ImportConfig.get_config(state.base_path)
	var completed_modifiers: Array[String] = []
	
	for config in list.configs:
		for modifier in config.modifiers:
			if not modifier.enabled:
				continue

			if modifier.get_script().get_global_name() in completed_modifiers:
				print("Skipping %s from %s because it was already ran" % [modifier.get_script().get_global_name(), config.resource_path])
				continue
				
			modifier.process_scene(state, root)
			completed_modifiers.append(modifier.get_script().get_global_name())
	
	return OK
