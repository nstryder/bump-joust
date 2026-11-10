extends Actor


@export var acceleration: float = 1000

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	super._integrate_forces(state)
	if not is_input_enabled:
		return

	var final_acceleration: float = acceleration
	state.apply_central_force(input_direction * final_acceleration)
