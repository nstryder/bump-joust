extends ModifierItem


@onready var bounce_actor: BounceActor = actor


func _ready() -> void:
	bounce_actor.landing_force_mod = 0.5
	bounce_actor.bounce_active_duration *= 2.0
	bounce_actor.bounce_cooldown *= 1.5
