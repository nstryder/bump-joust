extends ModifierItem


@onready var charge_actor: ChargeActor = actor


func _ready() -> void:
	charge_actor.knockback_take_modifier = 2.0
	charge_actor.knockback_give_modifier = 2.0
