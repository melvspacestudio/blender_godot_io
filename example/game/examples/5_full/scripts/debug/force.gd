extends Node3D

@onready
var sphere_scene := preload("res://examples/5_full/debug/sphere_influence.tscn")

var sphere: Node3D
var center: Vector3

#public static float Damp(float a, float b, float lambda, float dt)
#{
	#return Mathf.Lerp(a, b, 1 - Mathf.Exp(-lambda * dt))
#}

func _damp(a: Variant, b: Variant, lambda: float, delta: float) -> Variant:
	return lerp(a, b, 1 - exp(-lambda * delta))

func _physics_process(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		var space_state = get_world_3d().direct_space_state

		var origin = global_position - global_basis.z
		var end = origin - global_basis.z * 100
		
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		query.collide_with_areas = true

		var result = space_state.intersect_ray(query)
		if result:
			var position: Vector3 = result["position"]
			if not sphere:
				sphere = sphere_scene.instantiate()
				owner.add_child(sphere)
			
			var distance = max((position - global_position).length(), 3)
			var target = global_position - global_basis.z * distance
			
			center = _damp(center, target, 10, 0.5 * delta)
			sphere.global_position = center
			
			
		elif sphere:
			sphere.queue_free()
			sphere = null
			
	elif sphere:
			sphere.queue_free()
			sphere = null
		
