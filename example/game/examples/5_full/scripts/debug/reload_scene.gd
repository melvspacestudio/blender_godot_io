extends Node


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_pressed() and event.keycode == Key.KEY_R:
			get_tree().reload_current_scene()
	
