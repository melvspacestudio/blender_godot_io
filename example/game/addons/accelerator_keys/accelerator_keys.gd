@tool
extends EditorPlugin

var _popup_data: Dictionary[PopupMenu, Dictionary] = {}
var _opened_popups: Array[PopupMenu] = []

func _enter_tree() -> void:
	get_tree().node_added.connect(_on_node_added)
	for popup in get_tree().root.find_children("", "PopupMenu", true, false):
		_setup_popup(popup)

func _exit_tree() -> void:
	get_tree().node_added.disconnect(_on_node_added)
	for popup in get_tree().root.find_children("", "PopupMenu", true, false):
		_cleanup_popup(popup)

func _on_node_added(node: Node) -> void:
	if node is PopupMenu and not (node in _popup_data):
		_setup_popup(node)

func _setup_popup(popup: PopupMenu) -> void:
	var data := {
		"popup_callable": _on_popup.bind(popup),
		"input_callable": _on_input.bind(popup),
		"letter_indices": {},
		"number_indices": []
	}
	popup.about_to_popup.connect(data.popup_callable)
	popup.window_input.connect(data.input_callable)
	popup.allow_search = false
	_popup_data[popup] = data

func _cleanup_popup(popup: PopupMenu) -> void:
	var data = _popup_data.get(popup, null)
	if data:
		popup.about_to_popup.disconnect(data.popup_callable)
		popup.window_input.disconnect(data.input_callable)
		popup.allow_search = true
		_popup_data.erase(popup)

func _on_popup(popup: PopupMenu) -> void:
	var data = _popup_data[popup]
	data.letter_indices.clear()
	data.number_indices.clear()
	
	for i in popup.get_item_count():
		if popup.is_item_separator(i):
			continue
		var text := popup.get_item_text(i).remove_char(0x0332)
		for j in text.length():
			var char := text[j].to_lower()
			if char >= "a" and char <= "z" and not char in data.letter_indices:
				data.letter_indices[char] = i
				popup.set_item_text(i, text.insert(j + 1, "\u0332"))
				break
		data.number_indices.append(i)

func _on_input(event: InputEvent, popup: PopupMenu) -> void:
	if not (event is InputEventKey and event.is_pressed()):
		return

	var data = _popup_data[popup]
	var idx := -1
	if event.keycode >= KEY_0 and event.keycode <= KEY_9:
		var num = (event.keycode - KEY_1) % 10 + (10 if event.shift_pressed else 0)
		if num >= 0 and num < data.number_indices.size():
			idx = data.number_indices[num]
	elif event.keycode >= KEY_A and event.keycode <= KEY_Z:
		idx = data.letter_indices.get(char(event.keycode).to_lower(), -1)	
	if idx < 0:
		return
	
	popup.index_pressed.emit(idx)
	popup.id_pressed.emit(popup.get_item_id(idx))

	_opened_popups.append(popup)
	var submenu = popup.get_item_submenu_node(idx)
	if submenu:
		submenu.popup(Rect2(popup.position + Vector2i(popup.size.x, 0), Vector2.ZERO))
	else:
		for opened_popup in _opened_popups:
			opened_popup.hide()
		_opened_popups.clear()