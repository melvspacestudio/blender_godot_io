@tool
class_name BGIO_CollissionNodeModifier extends BGIO_NodeModifier

func _generate_node(state: GLTFState, gltf_node: GLTFNode, scene_parent: Node, node: Node) -> Node:
	if not node: return node
	if gltf_node.mesh == -1: return node
	
	var mesh = state.get_meshes()[gltf_node.mesh]
	var mesh_data = mesh.mesh.get_mesh()
	var extras = _get_extras(gltf_node)
	
	var is_convex: bool = extras.get("convex", true) == true
	
	if node is CollisionShape3D:
		var collision_node := node as CollisionShape3D
		if is_convex:
			collision_node.shape = mesh_data.create_convex_shape()
		else:
			collision_node.shape = mesh_data.create_trimesh_shape()
		
		return node
		
	if node is CollisionObject3D:
		var collision_node := CollisionShape3D.new()
		collision_node.name = "CollisionShape3D"
		node.add_child(collision_node)
		
		if is_convex:
			collision_node.shape = mesh_data.create_convex_shape()
		else:
			collision_node.shape = mesh_data.create_trimesh_shape()
		
		return node
		
	return node
