extends ModifierItem


@onready var slip_actor: SlipActor = actor


func _ready() -> void:
	slip_actor.ability_is_passive = false
	slip_actor.slip_can_paralyze = true
	slip_actor.slip_damping = 20
	slip_actor.slip_lifetime = 0.5
