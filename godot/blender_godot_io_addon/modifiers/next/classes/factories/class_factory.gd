@tool
class_name BGIO_ClassFactory extends Resource

func can_generate(state: GLTFState, gltf_node: GLTFNode, scene_parent: Node, node: Node) -> bool:
	return false

func generate_node(state: GLTFState, gltf_node: GLTFNode, scene_parent: Node, node: Node) -> Node:
	if gltf_node.mesh == -1:
		return _handle_empty_node(state, gltf_node, scene_parent, node)
	
	else:
		return _handle_mesh_node(state, gltf_node, scene_parent, node)

func create_class_instance(state: GLTFState, gltf_node: GLTFNode, scene_parent: Node, node: Node) -> Node:
	var classname = BGIO_ClassModifier_Utility.get_classname(gltf_node)
	if classname:
		var new_node = ClassDB.instantiate(classname)
		if new_node is not Node:
			return null
		
		new_node = new_node as Node
		new_node.name = gltf_node.resource_name
		
		var extras: Dictionary = BlenderNodes.get_extras(gltf_node)
		var properties: Array[Dictionary] = new_node.get_property_list()
		
		var available_keys: Array[String] = []
		for property in properties:
			if property["type"] == 0: continue
			available_keys.append(property["name"])
			
		for key in extras.keys():
			if key in available_keys:
				print("setting %s to %s" % [key, extras[key]])
				new_node.set(key, extras[key])
			else:
				print("skipping %s of %s" % [key, extras[key]])

		return new_node
		
	return null

func _handle_empty_node(state: GLTFState, gltf_node: GLTFNode, scene_parent: Node, node: Node) -> Node:
	return create_class_instance(state, gltf_node, scene_parent, node)

func _handle_mesh_node(state: GLTFState, gltf_node: GLTFNode, scene_parent: Node, node: Node) -> Node:
	var generated_node = _handle_empty_node(state, gltf_node, scene_parent, node)
	if not generated_node: return node
	
	var mesh := state.get_meshes()[gltf_node.mesh].mesh
	var mesh_node = ImporterMeshInstance3D.new()
	var properties: Array[Dictionary] = mesh_node.get_property_list()
	
	mesh_node.mesh = mesh
	mesh_node.name = "MeshInstance3D"
	
	#print('------------------')
	#print(gltf_node.original_name)
	var available_keys: Array[String] = []
	for property in properties:
		if property["type"] == 0: continue
		available_keys.append(property["name"])
		# TODO: apply params later to MeshInstance3D
		#print(property)
	
	#print('')
	
	generated_node.add_child(mesh_node)
	
	return generated_node
