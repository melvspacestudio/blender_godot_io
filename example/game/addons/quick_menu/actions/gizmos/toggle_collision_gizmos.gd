class_name QMToggleCollisionGizmos extends QMAction

const SHOWN = 0
const HIDDEN = 1
const HALF_HIDDEN = 2

func toggle_count(multistate: int) -> int:
	if multistate == SHOWN:
		return HIDDEN - SHOWN
	elif multistate == HIDDEN:
		return 2
	elif multistate == HALF_HIDDEN:
		return 2
		
	return 0

func get_key() -> Key:
	return Key.KEY_C

func get_label() -> String:
	return "Toggle Collisions"

func execute(context: Node):
	var active_scene = EditorInterface.get_edited_scene_root()
	
	var editor = EditorInterface.get_editor_viewport_3d().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()
	var toolbar = editor.get_child(0)
	
	for toolbar_node in QMNodeUtility.all_of(toolbar):
		if toolbar_node is not MenuButton: continue
		toolbar_node = toolbar_node as MenuButton
		
		if toolbar_node.text != "View": continue
		
		var popup_menu: PopupMenu = toolbar_node.get_popup()
		
		if not press_menu_item(popup_menu, "G̲izmos/Colli̲sionShape3D"):
			press_menu_item(popup_menu, "Gizmos/CollisionShape3D")	

func press_menu_item(popup_menu: PopupMenu, path: String):
	var parts = path.split("/")
	if parts.size() == 0:
		return false
		
	var target_item_text = parts[0]
	for item_index in popup_menu.item_count:
		var item_text = popup_menu.get_item_text(item_index)
		print(item_text)
		
		if item_text == target_item_text:
			if parts.size() == 1:
				var multistate = popup_menu.get_item_multistate(item_index)
				
				for i in toggle_count(multistate):
					popup_menu.id_pressed.emit(popup_menu.get_item_id(item_index))
					popup_menu.index_pressed.emit(item_index)
				
			else:
				var submenu = popup_menu.get_item_submenu_node(item_index)
				if not submenu: 
					return false
				
				popup_menu.set_focused_item(item_index)
				return press_menu_item(submenu, "/".join(parts.slice(1)))
		
		else:
			continue

	return false
	
