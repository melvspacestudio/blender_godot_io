@tool
class_name GGP_PrefabModifier extends GGP_NodeModifier

@export_dir
var prefab_dir: String = "prefabs"

@export
var extensions: Array[String] = [".tscn", ".scn", ".glb", ".gltf"]

func process_node(state: GLTFState, gltf_node: GLTFNode, json: Dictionary, node: Node) -> Node:
	var name = _get_name_from_node(node)
	if name.begins_with("$"):
		var dir = GGP_Path.resolve_at(self, prefab_dir)
		var prefab_path = dir.path_join(name.substr(1))
		var extras: Dictionary = node.get_meta("extras") if node.has_meta("extras") else {}
		var prefab: PackedScene
		
		for extension in extensions:
			if ResourceLoader.exists(prefab_path + extension):
				var loaded_prefab = ResourceLoader.load(prefab_path + extension)
				if loaded_prefab is PackedScene:
					prefab = loaded_prefab
					break

		if not prefab:
			print("Tried to load prefab at {path} but not found".format({"path": prefab_path + "[%s]" % "|".join(extensions)}))
		
		if extras.get("geometry_nodes", false):
			for child in node.get_children():
				GGP_NodeUtility.replace(child, prefab.instantiate(), extras)
				child.free()

			return node
		
		var prefab_node = prefab.instantiate()
		return prefab_node
		
	return node
