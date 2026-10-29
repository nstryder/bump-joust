extends Actor
class_name ChargeActor

# NOTES: 
# Max speed is determined by accel / damp

@export var acceleration: float = 2000
@export var charge_accel: float = 1300
@export_range(0, 1) var charging_speed_modifier: float = 0.5
@export var charge_force: float = 500

var is_charging: bool = false
var is_charging_released: bool = false


func _unhandled_key_input(event: InputEvent) -> void:
	var move_actions: Array[String] = ["move_left", "move_right", "move_up", "move_down"]
	if move_actions.any(event.is_action):
		input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if event.is_action("ability"):
		is_charging = event.is_pressed()
		is_charging_released = event.is_released()


func _ready() -> void:
	animation_playback.travel("walk")
	

func _process(_delta: float) -> void:
	var extra_speed_modifier: float = linear_velocity.length() / (acceleration / linear_damp)
	animation_tree["parameters/walk/TimeScale/scale"] = 1.0 + extra_speed_modifier


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	super._integrate_forces(state)
	var final_acceleration: float = acceleration
	if is_charging:
		final_acceleration *= charging_speed_modifier
	
	if not input_direction.is_zero_approx():
		last_nonzero_direction = input_direction
		if input_direction.x:
			last_nonzero_x = input_direction.x
		animation_tree["parameters/walk/BlendSpace2D/blend_position"] = last_nonzero_direction + Vector2(last_nonzero_x, 0)

	state.apply_central_force(input_direction * final_acceleration)
	
	if is_charging_released:
		is_charging_released = false
		state.apply_central_impulse(last_nonzero_direction * charge_accel)
	
	for i in state.get_contact_count():
		if linear_velocity.length() <= (acceleration / linear_damp):
			break
		var bumpee: RigidBody2D = state.get_contact_collider_object(i)
		var bump_normal: Vector2 = - state.get_contact_local_normal(i)
		bumpee.apply_central_impulse(bump_normal * charge_force)
