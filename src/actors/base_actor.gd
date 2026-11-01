extends RigidBody2D
class_name Actor


signal collided(state1: PhysicsDirectBodyState2D, state2: PhysicsDirectBodyState2D)

@export var recoil_intensity: float = 1.5
@export var sfx_death: AudioStream
@export var hit_stop_duration: float = 0.1
@export var is_player: bool = false


var input_direction := Vector2.ZERO
var last_nonzero_direction := Vector2.DOWN
var last_nonzero_x: float = 1.0


@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]
@onready var debug_speed: Label = $DEBUG_Speed
@onready var bump_sfx: AudioStreamPlayer2D = $BumpSfx
@onready var shadow_remote: RemoteTransform2D = $ShadowRemote
@onready var shadow: Shadow


func _ready() -> void:
	if not is_player:
		set_process_unhandled_key_input(false)
	animation_playback.travel("walk")


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	debug_speed.text = "%.0f \n" % (linear_velocity.length() / 10)

	if not input_direction.is_zero_approx():
		last_nonzero_direction = input_direction
		if input_direction.x:
			last_nonzero_x = input_direction.x
		animation_tree["parameters/walk/BlendSpace2D/blend_position"] = last_nonzero_direction + Vector2(last_nonzero_x, 0)

	collide(state)


func collide(state: PhysicsDirectBodyState2D) -> void:
	for i in state.get_contact_count():
		var other_party: Actor = state.get_contact_collider_object(i)
		var other_party_rid: RID = other_party.get_rid()
		var other_party_state: PhysicsDirectBodyState2D = PhysicsServer2D.body_get_direct_state(other_party_rid)
		collided.emit(self, state, other_party, other_party_state)


func die() -> void:
	var explosion := Explosion.construct()
	explosion.global_position = global_position
	get_tree().root.add_child(explosion)
	Audio.play_2d(sfx_death, global_position)
	if shadow:
		shadow.queue_free()
	queue_free()
