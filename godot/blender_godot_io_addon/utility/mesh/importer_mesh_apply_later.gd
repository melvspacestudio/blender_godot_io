@tool
class_name BGIO_ImporterMeshInstance3D_ApplyLater extends Node

@export
var properties: Dictionary[String, Variant] = {}

func _apply():
	var mesh_instance = get_parent()
	var available_keys: Array[String] = []
	
	for property in mesh_instance.get_property_list():
		if property["type"] == 0: continue
		available_keys.append(property["name"])
	
	for key in properties:
		if key in available_keys:
			mesh_instance.set(key, properties[key])

func _ready() -> void:
	if name != "_ApplyLater":
		queue_free()
		return

	if Engine.is_editor_hint():
		_apply()
	
	else:
		_apply()
		queue_free()
