@tool
## This modifier adjusts the anchor point of the nodes.
##
## For single child nodes it takes position of child as anchor.
##
## For multi child nodes it searches node with name _Root and uses its position as anchor for the object.
class_name BGIO_NormalizeTransformNodeModifier extends BGIO_NodeModifier

func _is_root_node(gltf_node: GLTFNode) -> bool:
	if gltf_node.mesh != -1: return false
	if _get_name_from_gltf(gltf_node).to_lower() != "_root": return false
	
	return true

## Find the Root marker node.
## It should be named "_Root" to be recognized as anchor of the object.
func _get_root_node(state: GLTFState, gltf_node: GLTFNode) -> GLTFNode:
	var nodes: Array[GLTFNode] = state.get_nodes()
	for child_id in gltf_node.children:
		var child := nodes[child_id]
		if _is_root_node(child):
			return child
			
	return null

#func _sort_meta_nodes(a: GLTFNode, b: GLTFNode) -> bool:
	#if a.original_name.begins_with("_") and not b.original_name.begins_with("_"):
		#return true
	#
	#return false
#
#
#func _sort_meta_children(nodes: Array[GLTFNode], ai: int, bi: int) -> bool:
	#var a = nodes[ai]
	#var b = nodes[bi]
	#return _sort_meta_nodes(a, b)
#
#
#func pre_generate(state: GLTFState) -> Error:
	#var array: Array[GLTFNode] = state.get_nodes()
	#var old_indices: Dictionary[int, GLTFNode] = {}
	#var new_indices: Dictionary[GLTFNode, int] = {}
	#
	#var index = 0
	#for node in array:
		#old_indices[index] = node
		#index += 1
		#
	#array.sort_custom(_sort_meta_nodes)
	#
	#index = 0
	#for node in array:
		#new_indices[node] = index
		#index += 1
	#
	#for node in array:
		#var children: Array[int] = []
		#for child_index in node.children:
			#var child_node = old_indices[child_index]
			#var new_index = new_indices[child_node]
			#
			#children.append(new_index)
		#
		#children.sort_custom(func(ai, bi): return _sort_meta_children(array, ai, bi))
		#node.children = PackedInt32Array(children)
#
	#state.set_nodes(array)
	#
	#return OK

# TODO: sort meta nodes first in gltf json
func generate_node(state: GLTFState, gltf_node: GLTFNode, scene_parent: Node, node: Node) -> Node:
	if gltf_node.parent == -1:
		if _is_root_node(gltf_node) and gltf_node.position != Vector3.ZERO:
			var delta = gltf_node.position
			for child: GLTFNode in state.get_nodes():
				child.position -= delta
				
		return node
	
	if gltf_node.mesh >= 0: 
		return node
	
	if gltf_node.children.size() == 1:
		var child_id = gltf_node.children[0]
		var child: GLTFNode = state.get_nodes()[child_id]
		
		var delta: Vector3 = child.position
		gltf_node.position += (gltf_node.rotation * delta) * gltf_node.scale
		child.position = Vector3.ZERO
		
	elif gltf_node.children.size() > 1:
		var root_node = _get_root_node(state, gltf_node)
		if root_node:
			var delta: Vector3 = root_node.position
			gltf_node.position += (gltf_node.rotation * delta) * gltf_node.scale
			
			for child_id in gltf_node.children:
				var child: GLTFNode = state.get_nodes()[child_id]
				child.position -= delta


	return node
