extends Actor
class_name SlipActor


enum SlipState {
	NONE,
	ACTIVE,
	COOLDOWN
}

@export var acceleration: float = 1000
@export var slip_accel: float = 2000
@export var slip_lifetime: float = 2.0
@export var slip_damping: float = 0.0
@export var _slip_duration: float = 1.0
@export var _slip_cooldown_duration: float = 1.0

var slip_can_paralyze: bool = false
var ability_is_passive: bool = true

signal slip_state_changed(value: SlipState)
var slip_state := SlipState.NONE:
	set(value):
		slip_state = value
		slip_state_changed.emit(value)

@onready var _slip_timer: Timer = $SlipTimer
@onready var _slip_cooldown: Timer = $SlipCooldown
@onready var _slip_interval_timer: Timer = $SlipIntervalTimer
@onready var sfx_slip: AudioStreamPlayer2D = $SfxSlip
@onready var slip_particles: CPUParticles2D = $SlipParticles


func _ready() -> void:
	super._ready()
	EventBus.slippy_spawned.emit(self)


func _process(delta: float) -> void:
	super._process(delta)
	var cooldown_percent: float = (1 - (_slip_cooldown.time_left / _slip_cooldown_duration)) * 100
	ability_cooldown_display.value = cooldown_percent


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	super._integrate_forces(state)
	if not is_input_enabled:
		return

	var final_acceleration: float = acceleration
	if slip_state == SlipState.ACTIVE:
		final_acceleration = slip_accel
			
	state.apply_central_force(input_direction * final_acceleration)


func on_ability_just_pressed(_state: PhysicsDirectBodyState2D) -> void:
	if slip_state != SlipState.NONE:
		return
	slip_state = SlipState.ACTIVE
	_slip_timer.start(_slip_duration)
	sfx_slip.play()
	slip_particles.emitting = true
	animation_playback.travel("twirl")


func _on_slip_timer_timeout() -> void:
	slip_state = SlipState.COOLDOWN
	_slip_interval_timer.stop()
	slip_particles.emitting = false
	animation_playback.travel("walk")
	_slip_cooldown.start(_slip_cooldown_duration)
	ability_cooldown_display.show()
	

func _on_slip_cooldown_timeout() -> void:
	slip_state = SlipState.NONE
	ability_cooldown_display.hide()
