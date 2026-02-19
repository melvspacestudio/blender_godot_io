@tool
class_name BGIO_PrefabModifier extends BGIO_NodeModifier

@export_dir
var prefab_dir: String = "prefabs"

func _generate_node(state: GLTFState, gltf_node: GLTFNode, scene_parent: Node, node: Node) -> Node:
	var name = _get_name(gltf_node)
	if name.begins_with("$"):
		var dir = PathUtils.resolve_at(self, prefab_dir)
		var prefab_path = dir.path_join(name.substr(1))
		if ResourceLoader.exists(prefab_path):
			var prefab = ResourceLoader.load(prefab_path)
			print(prefab)
		
	return node
