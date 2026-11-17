extends RigidBody2D
class_name Actor


# NOTES: 
# Max speed is determined by accel / damp


enum Controller {
	NONE,
	PLAYER,
	CPU
}


signal collided(state1: PhysicsDirectBodyState2D, state2: PhysicsDirectBodyState2D)

@export var archetype: Game.Archetypes
@export var knockback_give_modifier: float = 1.0
@export var knockback_take_modifier: float = 1.0
@export var sfx_death: AudioStream
@export var hit_stop_duration: float = 0.1
@export var controller := Controller.NONE
@export var is_input_enabled: bool = true
@export var is_invincible: bool = false
# @export var modifier_item

var input_direction := Vector2.ZERO
var last_nonzero_direction := Vector2.DOWN
var last_nonzero_x: float = 1.0

var is_ability_pressed: bool = false
var is_ability_just_pressed: bool = false
var is_ability_released: bool = false
var is_ability_just_released: bool = false

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]
@onready var debug_speed: Label = $DEBUG_Speed
@onready var bump_sfx: AudioStreamPlayer2D = $BumpSfx
@onready var shadow_remote: RemoteTransform2D = $ShadowRemote
@onready var shadow: Shadow
@onready var player_indicator: Sprite2D = $PlayerIndicator
@onready var player_arrow: Sprite2D = $PlayerArrow
@onready var ability_cooldown_display: TextureProgressBar = $AbilityCooldownDisplay


func _ready() -> void:
	if not controller == Controller.PLAYER:
		set_process_unhandled_key_input(false)
		set_process_unhandled_input(false)
		player_indicator.hide()
		player_arrow.hide()
	animation_playback.travel("walk")


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_echo():
		return

	var move_actions: Array[String] = ["move_left", "move_right", "move_up", "move_down"]
	if move_actions.any(event.is_action):
		input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		get_viewport().set_input_as_handled()

	if event.is_action("ability"):
		is_ability_pressed = event.is_pressed()
		is_ability_just_pressed = event.is_pressed()
		is_ability_released = event.is_released()
		is_ability_just_released = event.is_released()
		get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventMouseButton:
		return
	
	is_ability_pressed = event.is_action_pressed("mouse_ability")
	is_ability_just_pressed = event.is_action_pressed("mouse_ability")
	is_ability_released = event.is_action_released("mouse_ability")
	is_ability_just_released = event.is_action_released("mouse_ability")


func _process(_delta: float) -> void:
	if controller == Controller.PLAYER:
		control_player_mouse()


func control_player_mouse() -> void:
	if Input.is_action_pressed("mouse_move"):
		input_direction = global_position.direction_to(get_global_mouse_position())
	elif Input.is_action_just_released("mouse_move"):
		input_direction = Vector2.ZERO


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	debug_speed.text = "%.0f \n" % (linear_velocity.length() / 10)

	if not input_direction.is_zero_approx():
		last_nonzero_direction = input_direction
		if input_direction.x:
			last_nonzero_x = input_direction.x
		animation_tree["parameters/walk/BlendSpace2D/blend_position"] = last_nonzero_direction + Vector2(last_nonzero_x, 0)
		player_indicator.rotation = Vector2.UP.angle_to(input_direction)

	if is_ability_just_pressed:
		is_ability_just_pressed = false
		on_ability_just_pressed(state)

	if is_ability_just_released:
		is_ability_just_released = false
		on_ability_just_released(state)
	
	if is_ability_pressed:
		on_ability_pressed(state)
	

	if is_ability_released:
		on_ability_released(state)
	
	collide(state)


@warning_ignore("unused_parameter")
func on_ability_just_pressed(state: PhysicsDirectBodyState2D) -> void:
	pass

@warning_ignore("unused_parameter")
func on_ability_just_released(state: PhysicsDirectBodyState2D) -> void:
	pass

@warning_ignore("unused_parameter")
func on_ability_pressed(state: PhysicsDirectBodyState2D) -> void:
	pass

@warning_ignore("unused_parameter")
func on_ability_released(state: PhysicsDirectBodyState2D) -> void:
	pass


func collide(state: PhysicsDirectBodyState2D) -> void:
	for i in state.get_contact_count():
		var other_party: Actor = state.get_contact_collider_object(i)
		var other_party_rid: RID = other_party.get_rid()
		var other_party_state: PhysicsDirectBodyState2D = PhysicsServer2D.body_get_direct_state(other_party_rid)
		collided.emit(self, state, other_party, other_party_state)


func die() -> void:
	if is_queued_for_deletion() or is_invincible:
		return

	var explosion := Explosion.construct()
	explosion.global_position = global_position
	get_tree().root.add_child(explosion)

	var ring_out_particles := RingOutParticles.construct(-linear_velocity.normalized())
	ring_out_particles.global_position = global_position
	get_tree().root.add_child(ring_out_particles)
	ring_out_particles.restart()

	Audio.play_2d(sfx_death, global_position)
	if shadow:
		shadow.queue_free()
	queue_free()
