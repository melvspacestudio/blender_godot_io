@tool
class_name QMAction extends RefCounted

func get_key() -> Key:
	return Key.KEY_NONE

func get_label() -> String:
	return "<unknown>"

func execute(context: Node):
	pass
