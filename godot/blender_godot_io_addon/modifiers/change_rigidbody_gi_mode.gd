@tool
class_name ChangeRigidbodyGIMode extends NodeModifier


func _should_process(node: Node) -> bool:
	return node is RigidBody3D


func _process_node(node: Node) -> Node:
	_process_meshes_recursive(node)
	return node


func _process_meshes_recursive(node: Node) -> void:
	if node is MeshInstance3D or node is ImporterMeshInstance3D:
		BlenderNodes.apply_param(node, "gi_mode", MeshInstance3D.GI_MODE_DYNAMIC)
		
	for child in node.get_children():
		_process_meshes_recursive(child)
