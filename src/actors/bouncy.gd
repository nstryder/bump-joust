extends Actor
class_name BounceActor

enum BounceState {
	NONE,
	ACTIVE,
	COOLDOWN
}

@export var acceleration: float = 1000
@export var bounce_accel: float = 2000
@export var bounce_trajectory: Curve
@export var bounce_height: float = 48
@export var bounce_active_duration: float = 0.6
@export var bounce_cooldown: float = 1.0
@export var landing_radius_mod: float = 1.0
@export var landing_force_mod: float = 1.0


var _is_ability_pressed: bool = false

signal bounce_state_changed(value: BounceState)
var _bounce_state := BounceState.NONE:
	set(value):
		_bounce_state = value
		bounce_state_changed.emit(value)

var _tween: Tween

@onready var sprite: Sprite2D = $Sprite2D
@onready var bounce_cooldown_timer: Timer = $BounceCooldownTimer


func _ready() -> void:
	super._ready()


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_echo():
		return

	var move_actions: Array[String] = ["move_left", "move_right", "move_up", "move_down"]
	if move_actions.any(event.is_action):
		input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	_is_ability_pressed = event.is_action_pressed("ability")


func _start_sprite_jump() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_method(sprite_jump, 0.0, 1.0, bounce_active_duration)
	_tween.finished.connect(_on_bounce_tween_finished)


func sprite_jump(curve_x: float) -> void:
	sprite.position.y = bounce_trajectory.sample_baked(curve_x) * -bounce_height


# Both layer and mask must be toggled 
# Because a collision happens even if self's layer is off but self can still scan other bodies
func toggle_collision(value: bool) -> void:
	set_collision_layer_value(1, value)
	set_collision_mask_value(1, value)


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	super._integrate_forces(state)
	var final_acceleration: float = acceleration

	if _is_ability_pressed and _bounce_state == BounceState.NONE:
		_is_ability_pressed = false
		_bounce_state = BounceState.ACTIVE
		_start_sprite_jump()
		toggle_collision(false)

	if _bounce_state == BounceState.ACTIVE:
		final_acceleration = bounce_accel
			
	state.apply_central_force(input_direction * final_acceleration)


func _on_bounce_tween_finished() -> void:
	_bounce_state = BounceState.COOLDOWN
	bounce_cooldown_timer.start(bounce_cooldown)
	toggle_collision(true)
	var landing_force := LandingForce.construct(self, landing_force_mod, landing_radius_mod)
	add_sibling(landing_force)
	landing_force.global_position = global_position
	

func _on_bounce_cooldown_timer_timeout() -> void:
	_bounce_state = BounceState.NONE
