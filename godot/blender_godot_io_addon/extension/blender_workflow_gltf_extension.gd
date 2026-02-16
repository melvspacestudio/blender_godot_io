## Extends GLTFDocumentExtension to provide custom processing for Blender workflow glTF imports
## This class handles additional metadata and node processing for glTF files exported from Blender
@tool
class_name BlenderWorkflowGLTFExtension extends GLTFDocumentExtension

const CUSTOM_DATA = &"blender_godot_io_addon"

@export
var enabled: bool = true

@export
var modifiers: Array[Resource] = []


func _import_preflight(_state: GLTFState, _extensions: PackedStringArray) -> Error:
	return ERR_SKIP


func _import_node(state: GLTFState, gltf_node: GLTFNode, json: Dictionary, node: Node) -> Error:
	if "-skip" in state.filename:
		return OK
	
	if json.has("extras"):
		var data = _get_custom_data(state)
		var to_store = {node.name: json.extras}
		data.merge(to_store)

		state.set_additional_data(CUSTOM_DATA, data)
		node.set_meta("extras", json.extras)

	return OK


func _import_post(state: GLTFState, root: Node) -> Error:
	if "-skip" in state.filename:
		return OK

	var extras = _get_custom_data(state)
	_process_recursive(root, extras)
	return OK


func _get_custom_data(state: GLTFState) -> Dictionary:
	# Workaround for Godot 4.6+ where get_additional_data might throw an error if the key is missing
	# We use metadata on the state object to track if we've initialized our custom data
	if not state.has_meta("blender_godot_io_init"):
		state.set_additional_data(CUSTOM_DATA, {})
		state.set_meta("blender_godot_io_init", true)
		return {}
		
	var data = state.get_additional_data(CUSTOM_DATA)
	if data is Dictionary:
		return data
	return {}


## Recursively processes a node and its children, applying custom processing based on extras metadata
## Traverses the node hierarchy, potentially replacing nodes with processed versions
## 
## @param node The current node being processed
## @param extras A dictionary of all metadata from the original glTF import keyed by node names
## @return The processed node (which may be the original or a replacement)
func _process_recursive(node: Node, extras: Dictionary) -> Node:
	for child in node.get_children():
		if is_instance_valid(child):
			_process_recursive(child, extras)

	if modifiers:
		for modifier_res in modifiers:
			var modifier = modifier_res as NodeModifier
			if not node or not is_instance_valid(node):
				break

			if not modifier:
				continue
				
			var script: Script = modifier.get_script()
			if script and not script.is_tool():
				push_warning("Modifier %s is not a @tool script, skipping." % modifier.resource_path)
				continue
				
			if modifier.should_process(node):
				node = modifier.process(node)

	return node
