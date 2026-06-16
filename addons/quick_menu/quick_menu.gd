@tool
extends EditorPlugin

var listener: InputListener

func _enter_tree() -> void:
	if listener:
		listener.queue_free()
		
	listener = InputListener.new()
	get_editor_interface().get_base_control().add_child(listener)


func _exit_tree() -> void:
	listener.queue_free()
