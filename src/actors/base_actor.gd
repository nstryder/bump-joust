extends RigidBody2D
class_name Actor


signal collided(state1: PhysicsDirectBodyState2D, state2: PhysicsDirectBodyState2D)


@export var bump_intensity: float = 280
@export var sfx_death: AudioStream
@export var hit_stop_duration: float = 0.1


var input_direction := Vector2.ZERO
var last_nonzero_direction := Vector2.DOWN
var last_nonzero_x: float = 1.0


@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]
@onready var debug_speed: Label = $DEBUG_Speed
@onready var bump_sfx: AudioStreamPlayer2D = $BumpSfx


func _ready() -> void:
	animation_playback.travel("walk")


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	debug_speed.text = "Speed: %.1f \n" % linear_velocity.length()

	
	for i in state.get_contact_count():
		var bump_normal: Vector2 = state.get_contact_local_normal(i)
		state.apply_central_impulse(bump_normal * bump_intensity)
		var other_party: RigidBody2D = state.get_contact_collider_object(i)
		var other_party_rid: RID = other_party.get_rid()
		var other_party_state: PhysicsDirectBodyState2D = PhysicsServer2D.body_get_direct_state(other_party_rid)
		collided.emit(state, other_party_state)

		
func die() -> void:
	var explosion := Explosion.construct()
	explosion.global_position = global_position
	get_tree().root.add_child(explosion)
	Audio.play_2d(sfx_death, global_position)
	queue_free()
