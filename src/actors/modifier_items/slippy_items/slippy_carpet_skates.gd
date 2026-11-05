extends ModifierItem


@onready var slip_actor: SlipActor = actor


func _ready() -> void:
	slip_actor.slip_damping = 5
	slip_actor.slip_lifetime = 100.0
