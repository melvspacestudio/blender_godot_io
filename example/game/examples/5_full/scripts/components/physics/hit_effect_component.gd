class_name HitEffectComponent extends Node3D

# -- Export --

## The sound to play on impact
@export var hit_sound: AudioStream = load("res://examples/5_full/assets/sounds/book_hit_mono.ogg")

## Minimum velocity change required to trigger the sound
@export var impact_threshold: float = 1.5

## How much the impact strength affects the volume (0 = no effect, 1 = high effect)
@export var volume_scaling: float = 0.2

# -- Dependencies --

@onready
var parent: RigidBody3D = get_parent()

@onready 
var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

# -- State --

var prev_velocity: Vector3
var timer: float

# -- Logic --

func _ready() -> void:
	audio_player.stream = hit_sound
	audio_player.bus = &"SFX"
	
	parent.body_entered.connect(_handle_body_entered)

func _handle_body_entered(other_body: PhysicsBody3D):
	var other_body_velocity := Vector3.ZERO
	if other_body is RigidBody3D:
		other_body_velocity = other_body.linear_velocity
		
	var velocity_difference = parent.linear_velocity - other_body_velocity
	var intensity = clamp(velocity_difference.length(), 0.0, 4.0)
	
	if intensity > 0.25:
		_play_hit_effect(intensity)


func _play_hit_effect(intensity: float) -> void:
	if audio_player and not audio_player.playing:
		# Slight randomization of pitch makes repetitive hits sound more natural
		audio_player.pitch_scale = randf_range(0.9, 1.1)
		
		# Optional: Adjust volume based on how hard the hit was
		var volume_db = clamp(linear_to_db(intensity * volume_scaling), -20, 0)
		audio_player.volume_db = volume_db
		
		audio_player.play()
