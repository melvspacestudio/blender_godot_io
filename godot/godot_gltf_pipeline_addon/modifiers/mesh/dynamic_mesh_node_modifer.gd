@tool
class_name GGP_DynamicMesh_NodeModifier extends GGP_NodeModifier

func _make_rigidbody_dynamic(body: RigidBody3D):
	for child in GGP_NodeUtility.all_of(body):
		if child is ImporterMeshInstance3D:
			_apply_later(child, {"gi_mode": MeshInstance3D.GIMode.GI_MODE_DYNAMIC})


func process_node(state: GLTFState, gltf_node: GLTFNode, json: Dictionary, node: Node) -> Node:
	if node is RigidBody3D:
		_make_rigidbody_dynamic(node)
	
	return node
