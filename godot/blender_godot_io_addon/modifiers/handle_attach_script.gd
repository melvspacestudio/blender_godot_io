@tool
class_name HandleAttachScript extends NodeModifier

const EXTRAS_CLASS_NAME = &"class_name"
const EXTRAS_ATTACH_SCRIPT = &"attach_script"

func _should_process(node: Node) -> bool:
	var script_name = get_script_name(node)
	if script_name.is_empty():
		return false
	
	return find_script(script_name) != null


func _process_node(node: Node) -> Node:
	var script_name = get_script_name(node)
	var script_data = find_script(script_name)
	
	if not script_data:
		return node
		
	var path = script_data.get("path")
	if not path:
		return node
		
	var script = load(path)
	if not script:
		push_warning("Failed to load script at path: %s" % path)
		return node
	
	_log("attaching script %s to %s" % [path, node.name])
	
	node.set_script(script)
	
	return node


func get_script_name(node: Node) -> String:
	var extras = _get_extras(node)
	var classname = extras.get(EXTRAS_CLASS_NAME)
	var script = extras.get(EXTRAS_ATTACH_SCRIPT)
	
	if script is String and not script.is_empty():
		return script
		
	if classname is String and not classname.is_empty():
		if ClassDB.class_exists(classname):
			return ""

		return classname
	
	return ""


func find_script(name: String) -> Dictionary:
	for class_item in ProjectSettings.get_global_class_list():
		if class_item.get("class") == name:
			return class_item
		
	return {}
