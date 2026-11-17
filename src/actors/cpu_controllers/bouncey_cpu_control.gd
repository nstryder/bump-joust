extends BaseCpuControl


@onready var bounce_actor: BounceActor = actor


func _ready() -> void:
	super._ready()
	if bounce_actor.controller == Actor.Controller.CPU:
		bounce_actor.bounce_state_changed.connect(_on_bounce_state_changed)
		bounce_actor.is_ability_pressed = true
		bounce_actor.is_ability_just_pressed = true


func _process(delta: float) -> void:
	super._process(delta)


func _on_bounce_state_changed(value: BounceActor.BounceState) -> void:
	if value == BounceActor.BounceState.NONE:
		bounce_actor.is_ability_pressed = true
		bounce_actor.is_ability_just_pressed = true
