@tool
class_name GGP_ClassFactory extends Resource

const RESERVED_EXTRA_KEYS: Array[String] = ["class_name", "geometry_nodes"]

var last_generation_error := ""


func can_generate(state: GLTFState, gltf_node: GLTFNode, scene_parent: Node, node: Node) -> bool:
	return false


func generate_node(state: GLTFState, gltf_node: GLTFNode, scene_parent: Node, node: Node) -> Node:
	last_generation_error = ""
	if gltf_node.mesh == -1:
		return _handle_empty_node(state, gltf_node, scene_parent, node)

	else:
		return _handle_mesh_node(state, gltf_node, scene_parent, node)


func create_class_instance(state: GLTFState, gltf_node: GLTFNode, scene_parent: Node, node: Node) -> Node:
	var result := create_class_instance_result(state, gltf_node, scene_parent, node)
	return result.get("node", null)


func create_class_instance_result(state: GLTFState, gltf_node: GLTFNode, scene_parent: Node, node: Node) -> Dictionary:
	var classname := GGP_ClassModifier_Utility.get_requested_classname(gltf_node)
	if classname.is_empty():
		last_generation_error = "no class name was requested"
		return {"node": null, "class_name": classname, "error": last_generation_error}
	if not ClassDB.class_exists(classname):
		last_generation_error = "class does not exist"
		return {"node": null, "class_name": classname, "error": last_generation_error}
	if not ClassDB.can_instantiate(classname):
		last_generation_error = "class cannot be instantiated"
		return {"node": null, "class_name": classname, "error": last_generation_error}

	var instance := ClassDB.instantiate(classname)
	if instance is not Node:
		if instance is Object and instance is not RefCounted:
			(instance as Object).free()
		last_generation_error = "class did not instantiate a Node"
		return {"node": null, "class_name": classname, "error": last_generation_error}

	var new_node := instance as Node
	new_node.name = gltf_node.resource_name
	_apply_extras_to_node(new_node, classname, GGP_NodeUtility.get_extras(gltf_node))
	return {"node": new_node, "class_name": classname, "error": ""}


func _apply_extras_to_node(target: Node, classname: String, extras: Dictionary) -> void:
	for key in extras.keys():
		if key is not String:
			continue

		var result := GGP_NodeUtility.apply_imported_property(target, key, extras[key], RESERVED_EXTRA_KEYS)
		if result.get("status", "") == GGP_NodeUtility.IMPORTED_PROPERTY_FAILED:
			push_warning(
				"Could not apply imported property `%s` to class `%s`: %s. Value type: `%s`."
				% [key, classname, result.get("reason", "unknown reason"), type_string(typeof(extras[key]))]
			)


func _handle_empty_node(state: GLTFState, gltf_node: GLTFNode, scene_parent: Node, node: Node) -> Node:
	return create_class_instance(state, gltf_node, scene_parent, node)


func _handle_mesh_node(state: GLTFState, gltf_node: GLTFNode, scene_parent: Node, node: Node) -> Node:
	var generated_node = _handle_empty_node(state, gltf_node, scene_parent, node)
	if not generated_node: return node

	var mesh := state.get_meshes()[gltf_node.mesh].mesh
	var mesh_node = ImporterMeshInstance3D.new()

	mesh_node.mesh = mesh
	mesh_node.name = "MeshInstance3D"
	generated_node.add_child(mesh_node)

	return generated_node
