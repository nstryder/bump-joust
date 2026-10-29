extends Actor
class_name ChargeActor

# NOTES: 
# Max speed is determined by accel / damp

@export var acceleration: float = 2000
@export var charge_accel: float = 1000
@export_range(0, 1) var charging_speed_modifier: float = 0.5
@export var charge_force: float = 500
@export var charge_active_time: float = 0.2
@export var charge_startup_time: float = 1.0

var is_charging_pressed: bool = false
var is_charging_released: bool = false

var is_charging_active: bool = false
var is_charging_ready: bool = false

@onready var charge_startup_timer: Timer = $ChargeStartupTimer
@onready var charge_active_timer: Timer = $ChargeActiveTimer
@onready var big_bump_sfx: AudioStreamPlayer2D = $BigBumpSfx
@onready var charge_press_sfx: AudioStreamPlayer2D = $ChargePressSfx
@onready var charge_ready_sfx: AudioStreamPlayer2D = $ChargeReadySfx
@onready var charge_release_sfx: AudioStreamPlayer2D = $ChargeReleaseSfx
@onready var charge_vfx: AnimatedSprite2D = $ChargeVfx
@onready var charge_ready_vfx: AnimatedSprite2D = $ChargeReadyVfx


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_echo():
		return

	var move_actions: Array[String] = ["move_left", "move_right", "move_up", "move_down"]
	if move_actions.any(event.is_action):
		input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if event.is_action("ability"):
		is_charging_pressed = event.is_pressed()
		if event.is_pressed():
			charge_startup_timer.start()
			charge_press_sfx.play()
			charge_vfx.play("startup")
			charge_vfx.show()
		is_charging_released = event.is_released()


func _ready() -> void:
	animation_playback.travel("walk")
	charge_active_timer.wait_time = charge_active_time
	charge_startup_timer.wait_time = charge_startup_time
	charge_ready_vfx.animation_finished.connect(charge_ready_vfx.hide)
	

func _process(_delta: float) -> void:
	var extra_speed_modifier: float = linear_velocity.length() / (acceleration / linear_damp)
	animation_tree["parameters/walk/TimeScale/scale"] = 1.0 + extra_speed_modifier


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	super._integrate_forces(state)
	var final_acceleration: float = acceleration
	if is_charging_pressed:
		final_acceleration *= charging_speed_modifier
	
	if not input_direction.is_zero_approx():
		last_nonzero_direction = input_direction
		if input_direction.x:
			last_nonzero_x = input_direction.x
		animation_tree["parameters/walk/BlendSpace2D/blend_position"] = last_nonzero_direction + Vector2(last_nonzero_x, 0)

	state.apply_central_force(input_direction * final_acceleration)
	
	if is_charging_released:
		is_charging_released = false
		charge_vfx.hide()
		if is_charging_ready:
			is_charging_ready = false
			charge_active_timer.start()
			is_charging_active = true
			state.apply_central_impulse(last_nonzero_direction * charge_accel)
			charge_release_sfx.play()
		else:
			charge_startup_timer.stop()
	
	
	for i in state.get_contact_count():
		if not is_charging_active:
			break
		var bumpee: RigidBody2D = state.get_contact_collider_object(i)
		var bump_normal: Vector2 = - state.get_contact_local_normal(i)
		bumpee.apply_central_impulse(bump_normal * charge_force)
		big_bump_sfx.play()
		print("Big bump!")


func _on_charge_active_timer_timeout() -> void:
	is_charging_active = false


func _on_charge_startup_timer_timeout() -> void:
	charge_ready_sfx.play()
	charge_vfx.play("ready")
	charge_ready_vfx.show()
	charge_ready_vfx.play("default")
	is_charging_ready = true
