class_name QMBakeLightsAction extends QMAction

func get_key() -> Key:
	return Key.KEY_B

func get_label() -> String:
	return "Bake Lights"

func execute(context: Node):
	await context.get_tree().create_timer(0.25).timeout

	var active_scene = EditorInterface.get_edited_scene_root()
	
	var selection = EditorInterface.get_selection()
	var selected_nodes = selection.get_selected_nodes()
	
	var editor = EditorInterface.get_editor_viewport_3d().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()
	var toolbar = editor.get_child(0)
	
	for node in QMNodeUtility.all_of(active_scene):
		if node is LightmapGI:
			selection.clear()
			selection.add_node(node)
			
			await context.get_tree().create_timer(0.25).timeout
			
			for toolbar_node in QMNodeUtility.all_of(toolbar):
				if toolbar_node is not Button: continue
				if toolbar_node.text != "Bake Lightmaps": continue
				toolbar_node = toolbar_node as Button
				toolbar_node.pressed.emit()

	selection.clear()
	for selected in selected_nodes:
		selection.add_node(selected)
