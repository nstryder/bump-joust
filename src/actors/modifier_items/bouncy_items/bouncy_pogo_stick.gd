extends ModifierItem

@onready var bounce_actor: BounceActor = actor


func _ready() -> void:
	bounce_actor.landing_radius_mod = 0.5
	bounce_actor.bounce_cooldown *= 0.6
