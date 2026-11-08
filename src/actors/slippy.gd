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
var _is_ability_pressed: bool = false

signal slip_state_changed(value: SlipState)
var slip_state := SlipState.ACTIVE:
	set(value):
		slip_state = value
		slip_state_changed.emit(value)

@onready var _slip_timer: Timer = $SlipTimer
@onready var _slip_cooldown: Timer = $SlipCooldown
@onready var _slip_interval_timer: Timer = $SlipIntervalTimer


func _ready() -> void:
	super._ready()
	EventBus.slippy_spawned.emit(self)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_echo():
		return

	var move_actions: Array[String] = ["move_left", "move_right", "move_up", "move_down"]
	if move_actions.any(event.is_action):
		input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	_is_ability_pressed = event.is_action_pressed("ability")


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	super._integrate_forces(state)
	if not is_input_enabled:
		return

	var final_acceleration: float = acceleration

	if not ability_is_passive and _is_ability_pressed and slip_state == SlipState.NONE:
		_is_ability_pressed = false
		slip_state = SlipState.ACTIVE
		_slip_timer.start(_slip_duration)
	
	if slip_state == SlipState.ACTIVE:
		final_acceleration = slip_accel
			
	state.apply_central_force(input_direction * final_acceleration)


func _on_slip_timer_timeout() -> void:
	slip_state = SlipState.COOLDOWN
	_slip_interval_timer.stop()
	_slip_cooldown.start(_slip_cooldown_duration)
	

func _on_slip_cooldown_timeout() -> void:
	slip_state = SlipState.NONE
