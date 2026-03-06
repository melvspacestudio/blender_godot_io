extends Area3D

var radius: float = 2.0;

@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	var shape := SphereShape3D.new()
	shape.radius = radius
	
	collision_shape_3d.shape = shape


func _physics_process(delta: float) -> void:
	ImmediateGizmos3D.line_sphere(global_position, radius)
	for body in get_overlapping_bodies():
		if body is RigidBody3D:
			body.apply_force((global_position - body.global_position).normalized() * body.mass * 100)

func _exit_tree() -> void:
	for body in get_overlapping_bodies():
		if body is RigidBody3D:
			body.apply_impulse((body.global_position - global_position).normalized() * body.mass * 10)
