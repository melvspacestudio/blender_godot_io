extends Node3D

var projectile_scene := preload("res://examples/5_full/debug/projectile.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED: return
	
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			var projectile: RigidBody3D = projectile_scene.instantiate()
			owner.add_child(projectile)
			
			projectile.mass = 10.0
			projectile.global_position = global_position - global_basis.z
			projectile.apply_impulse(-global_basis.z * 10 * projectile.mass)
