@tool
class_name ApplyLaterNode extends Node

@export
var extras: Dictionary

func _ready() -> void:
	if get_parent() is MeshInstance3D:
		for key in extras.keys():
			BlenderNodes.apply_param(get_parent(), key, extras[key])
		
	if not Engine.is_editor_hint():
		queue_free()
