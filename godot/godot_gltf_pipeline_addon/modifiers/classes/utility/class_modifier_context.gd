@tool
class_name GGP_ClassModifier_Utility

static func get_classname(gltf_node: GLTFNode) -> String:
	var classname = GGP_NodeUtility.get_extras(gltf_node).get("class_name", GGP_NodeUtility.get_name_from_gltf(gltf_node))
	if classname is String and not classname.is_empty():
		if ClassDB.class_exists(classname):
			return classname
			
	return ""
	
