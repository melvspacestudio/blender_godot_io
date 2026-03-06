class_name InputListener extends Node

var scene: PackedScene = load("res://addons/quick_menu/quick_menu.tscn")
var focus: Node

func _enter_tree() -> void:
	var viewport = EditorInterface.get_editor_viewport_3d()
	var main_window = viewport.get_window()
	main_window.gui_focus_changed.connect(_main_window_focus_changed)


func _exit_tree() -> void:
	var viewport = EditorInterface.get_editor_viewport_3d()
	var main_window = viewport.get_window()
	main_window.gui_focus_changed.disconnect(_main_window_focus_changed)


func _main_window_focus_changed(control: Node):
	focus = control
	

func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventKey: return
	event = event as InputEventKey
	
	if event.is_echo(): return
	if not event.is_pressed(): return
	if (event as InputEventKey).keycode != KEY_D: return
	if focus != EditorInterface.get_editor_viewport_3d().get_parent().get_parent().get_child(1): return
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT): return
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT): return
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE): return
	if event.shift_pressed: return
	if event.alt_pressed: return
	if event.ctrl_pressed: return
	
	EditorInterface.popup_dialog_centered_clamped(scene.instantiate())
