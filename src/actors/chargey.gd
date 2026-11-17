extends Actor
class_name ChargeActor

enum ChargeState {
	NONE,
	CHARGING,
	READY,
	ACTIVE
}

@export var acceleration: float = 1000
@export var charge_launch_accel: float = 1000
@export_range(0, 1) var charging_speed_modifier: float = 0.01
@export var charge_impact_force: float = 500
@export var charge_active_time: float = 0.2
@export var charge_startup_time: float = 1.0

var charge_state := ChargeState.NONE

@onready var charge_startup_timer: Timer = $ChargeStartupTimer
@onready var charge_active_timer: Timer = $ChargeActiveTimer
@onready var big_bump_sfx: AudioStreamPlayer2D = $BigBumpSfx
@onready var charge_press_sfx: AudioStreamPlayer2D = $ChargePressSfx
@onready var charge_ready_sfx: AudioStreamPlayer2D = $ChargeReadySfx
@onready var charge_release_sfx: AudioStreamPlayer2D = $ChargeReleaseSfx
@onready var charge_vfx: AnimatedSprite2D = $ChargeVfx
@onready var charge_ready_vfx: AnimatedSprite2D = $ChargeReadyVfx
@onready var charge_active_particles: CPUParticles2D = $ChargeActiveParticles


func _ready() -> void:
	super._ready()
	charge_active_timer.wait_time = charge_active_time
	charge_startup_timer.wait_time = charge_startup_time
	charge_ready_vfx.animation_finished.connect(charge_ready_vfx.hide)
		

func _process(delta: float) -> void:
	super._process(delta)
	var extra_speed_modifier: float = linear_velocity.length() / (acceleration / linear_damp)
	animation_tree["parameters/walk/TimeScale/scale"] = 1.0 + extra_speed_modifier
	var ability_percent: float = (1 - (charge_startup_timer.time_left / charge_startup_time)) * 100
	ability_cooldown_display.value = ability_percent
	

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	super._integrate_forces(state)
	if not is_input_enabled:
		return

	var final_acceleration: float = acceleration
	if charge_state in [ChargeState.CHARGING, ChargeState.READY]:
		final_acceleration *= charging_speed_modifier

	state.apply_central_force(input_direction * final_acceleration)


func on_ability_just_pressed(_state: PhysicsDirectBodyState2D) -> void:
	charge_state = ChargeState.CHARGING
	charge_startup_timer.start()
	charge_press_sfx.play()
	charge_vfx.play("startup")
	charge_vfx.show()
	ability_cooldown_display.show()


func on_ability_just_released(state: PhysicsDirectBodyState2D) -> void:
	charge_vfx.hide()
	ability_cooldown_display.hide()
	if charge_state == ChargeState.READY:
		charge_active_timer.start()
		charge_state = ChargeState.ACTIVE
		state.apply_central_impulse(last_nonzero_direction * charge_launch_accel)
		charge_release_sfx.play()
		charge_active_particles.emitting = true
	else:
		charge_startup_timer.stop()
		charge_state = ChargeState.NONE


func collide(state: PhysicsDirectBodyState2D) -> void:
	super.collide(state)
	for i in state.get_contact_count():
		if charge_state != ChargeState.ACTIVE:
			break
		var bumpee: RigidBody2D = state.get_contact_collider_object(i)
		var bump_normal: Vector2 = state.get_contact_local_normal(i)
		bumpee.apply_central_impulse(-bump_normal * charge_impact_force)
		big_bump_sfx.play()
		print("Big bump!")


func _on_charge_active_timer_timeout() -> void:
	charge_state = ChargeState.NONE
	charge_active_particles.emitting = false


func _on_charge_startup_timer_timeout() -> void:
	charge_state = ChargeState.READY
	charge_ready_sfx.play()
	charge_vfx.play("ready")
	charge_ready_vfx.show()
	charge_ready_vfx.play("default")
	ability_cooldown_display.hide()
