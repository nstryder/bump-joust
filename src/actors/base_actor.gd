extends RigidBody2D
class_name Actor


@export var bump_intensity: float = 280


var input_direction := Vector2.ZERO
var last_nonzero_direction := Vector2.DOWN
var last_nonzero_x: float = 1.0


@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]
@onready var debug_speed: Label = $DEBUG_Speed


func _ready() -> void:
	animation_playback.travel("walk")


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	debug_speed.text = "Speed: %.1f \n" % linear_velocity.length()

	
	for i in state.get_contact_count():
		var bump_normal: Vector2 = state.get_contact_local_normal(i)
		state.apply_central_impulse(bump_normal * bump_intensity)


func die() -> void:
	var explosion := Explosion.construct()
	explosion.global_position = global_position
	get_tree().root.add_child(explosion)
