extends Actor


@export var acceleration: float = 1000


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	super._integrate_forces(state)
	if not is_input_enabled:
		return

	var final_acceleration: float = acceleration
	state.apply_central_force(input_direction * final_acceleration)
