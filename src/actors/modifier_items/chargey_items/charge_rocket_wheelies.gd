extends ModifierItem


@onready var charge_actor: ChargeActor = actor


func _ready() -> void:
	charge_actor.charge_startup_time *= 2
	charge_actor.charge_launch_accel *= 2
	charge_actor.charge_impact_force *= 1.5
