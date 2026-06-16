@tool
class_name GGP_ClassModifier_Utility

static func get_requested_classname(gltf_node: GLTFNode) -> String:
	var extras := GGP_NodeUtility.get_extras(gltf_node)
	var classname = extras.get("class_name", GGP_NodeUtility.get_name_from_gltf(gltf_node))
	if classname is String and not classname.is_empty():
		return classname

	return ""


static func has_explicit_classname(gltf_node: GLTFNode) -> bool:
	var extras := GGP_NodeUtility.get_extras(gltf_node)
	var classname = extras.get("class_name", null)
	return classname is String and not classname.is_empty()


static func get_classname(gltf_node: GLTFNode) -> String:
	var classname := get_requested_classname(gltf_node)
	if not classname.is_empty() and ClassDB.class_exists(classname):
		return classname

	return ""

