@tool
class_name BGIO_MaterialDebugProcessor extends BGIO_Processor


func _process_scene(state: GLTFState, root: Node) -> Error:
	_handle_node(root)
	return OK


func _handle_node(node: Node):
	for child in node.get_children():
		_handle_node(child)
		
	if node is ImporterMeshInstance3D:
		var materials: Array[Material] = []
		var textures: Array[Texture] = []
		for i in node.mesh.get_surface_count():
			var material = node.mesh.get_surface_material(i) as StandardMaterial3D
			materials.append(material)
			textures.append(material.albedo_texture)
			
		var label := Label3D.new()
		label.text = """
		Materials:
			{materials}
			
		Textures:
			{textures}
		""".format({
			"materials": "\n".join(materials.map(func (it: Material): return it.resource_path)),
			"textures": "\n".join(textures.map(func (it: Texture2D): return it.resource_path)),
		})
		
		
		label.position.y = 2.0
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		
		node.add_child(label)
		label.owner = node.owner
