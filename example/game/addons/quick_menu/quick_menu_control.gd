@tool
extends PopupMenu

@onready
var tree: QMTree = QMTree.load_tree("res://addons/quick_menu/actions/")

func _create_popup_menu(group: QMIndex) -> PopupMenu:
	var _self = self
	var menu := PopupMenu.new()
	var groups = group.load_groups()
	var actions = group.load_actions()
	
	var handler = func(index):
		print(index)
		if index < groups.size():
			return

		var action = actions[index - groups.size()]
		action.execute(_self)
	
	menu.index_pressed.connect(handler)
	
	for child_group: QMIndex in group.load_groups():
		var key = child_group.key
		var label = child_group.name
		
		if key != KEY_NONE:
			label = "({key}) {label}".format({
				"key": OS.get_keycode_string(key),
				"label": label
			})

		menu.add_submenu_node_item(label, _create_popup_menu(child_group))
	
	for action in group.load_actions():
		var key = action.get_key()
		var label = action.get_label()
		
		if key != KEY_NONE:
			label = "({key}) {label}".format({
				"key": OS.get_keycode_string(key),
				"label": label
			})

		menu.add_item(label, -1, key)
	
	return menu

func _ready() -> void:
	if is_part_of_edited_scene(): return
	
	index_pressed.connect(_handle_index_pressed)
	
	for group: QMIndex in tree.groups:
		var key = group.key
		var label = group.name
		
		if key != KEY_NONE:
			label = "({key}) {label}".format({
				"key": OS.get_keycode_string(key),
				"label": label
			})

		add_submenu_node_item(label, _create_popup_menu(group))
	
	for action in tree.actions:
		var key = action.get_key()
		var label = action.get_label()
		
		if key != KEY_NONE:
			label = "({key}) {label}".format({
				"key": OS.get_keycode_string(key),
				"label": label
			})

		add_item(label, -1, key)
	
func _handle_index_pressed(index: int):
	if index < tree.groups.size():
		return

	var action = tree.actions[index - tree.groups.size()]
	action.execute(self)
