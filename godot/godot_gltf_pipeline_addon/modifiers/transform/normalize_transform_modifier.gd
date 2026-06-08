@tool
## This modifier adjusts the anchor point of the nodes.
##
## For single mesh assets it clears the mesh node position.
##
## For multi child nodes it searches node with name _Root or _Origin and uses its position as anchor for the object.
class_name GGP_NormalizeTransformNodeModifier extends GGP_NodeModifier

const NORMALIZED_META := &"GGP_NormalizeTransformNodeModifier_normalized"

func _is_root_node(gltf_node: GLTFNode) -> bool:
	if gltf_node.mesh != -1: return false
	var node_name := _get_name_from_gltf(gltf_node).to_lower()
	if node_name != "_root" and node_name != "_origin": return false
	
	return true

func _get_root_indices(nodes: Array[GLTFNode]) -> Array[int]:
	var roots: Array[int] = []
	for index in range(nodes.size()):
		if nodes[index].parent == -1:
			roots.append(index)
	
	return roots

func _get_root_node_index(nodes: Array[GLTFNode], indices: Array[int]) -> int:
	for index in indices:
		if _is_root_node(nodes[index]):
			return index
	
	return -1

## Find the Root marker node.
## It should be named "_Root" or "_Origin" to be recognized as anchor of the object.
func _get_root_node(state: GLTFState, gltf_node: GLTFNode) -> GLTFNode:
	return _get_root_node_from_nodes(state.get_nodes(), gltf_node)

func _get_root_node_from_nodes(nodes: Array[GLTFNode], gltf_node: GLTFNode) -> GLTFNode:
	for child_id in gltf_node.children:
		var child := nodes[child_id]
		if _is_root_node(child):
			return child
			
	return null

func _get_only_mesh_node(nodes: Array[GLTFNode]) -> GLTFNode:
	var mesh_node: GLTFNode = null
	
	for gltf_node in nodes:
		if gltf_node.mesh == -1:
			continue
		
		if mesh_node:
			return null
		
		mesh_node = gltf_node
	
	return mesh_node

func _normalize_root_nodes(nodes: Array[GLTFNode]) -> void:
	var roots := _get_root_indices(nodes)
	var root_node_index := _get_root_node_index(nodes, roots)
	
	if root_node_index != -1:
		var delta := nodes[root_node_index].position
		for index in roots:
			nodes[index].position -= delta
		return
	
	var mesh_node := _get_only_mesh_node(nodes)
	if mesh_node and mesh_node.parent == -1:
		mesh_node.position = Vector3.ZERO

func _normalize_child_nodes(nodes: Array[GLTFNode], gltf_node: GLTFNode) -> void:
	if gltf_node.parent == -1:
		return
	if gltf_node.mesh >= 0:
		return
	
	if gltf_node.children.size() == 1:
		var child_id = gltf_node.children[0]
		var child: GLTFNode = nodes[child_id]
		
		var delta: Vector3 = child.position
		gltf_node.position += (gltf_node.rotation * delta) * gltf_node.scale
		child.position = Vector3.ZERO
		
	elif gltf_node.children.size() > 1:
		var root_node = _get_root_node_from_nodes(nodes, gltf_node)
		if root_node:
			var delta: Vector3 = root_node.position
			gltf_node.position += (gltf_node.rotation * delta) * gltf_node.scale
			
			for child_id in gltf_node.children:
				var child: GLTFNode = nodes[child_id]
				child.position -= delta

func _normalize_state(state: GLTFState) -> void:
	if state.has_meta(NORMALIZED_META):
		return
	
	var nodes: Array[GLTFNode] = state.get_nodes()
	if nodes.is_empty():
		return
	
	_normalize_root_nodes(nodes)
	
	for gltf_node in nodes:
		_normalize_child_nodes(nodes, gltf_node)
	
	state.set_nodes(nodes)
	state.set_meta(NORMALIZED_META, true)

func pre_generate(state: GLTFState) -> Error:
	_normalize_state(state)
	
	return OK

func generate_node(state: GLTFState, gltf_node: GLTFNode, scene_parent: Node, node: Node) -> Node:
	_normalize_state(state)
	
	return node
