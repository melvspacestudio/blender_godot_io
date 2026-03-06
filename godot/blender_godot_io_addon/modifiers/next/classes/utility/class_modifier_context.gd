@tool
class_name BGIO_ClassModifier_Utility

static func get_classname(gltf_node: GLTFNode) -> String:
	var classname = BlenderNodes.get_extras(gltf_node).get("class_name", BlenderNodes.get_name_from_gltf(gltf_node))
	if classname is String and not classname.is_empty():
		if ClassDB.class_exists(classname):
			return classname
			
	return ""
	
