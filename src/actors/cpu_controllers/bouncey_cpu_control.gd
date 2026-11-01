extends BaseCpuControl


@onready var bounce_actor: BounceActor = actor


func _ready() -> void:
	super._ready()
	bounce_actor.bounce_state_changed.connect(_on_bounce_state_changed)
	bounce_actor._is_ability_pressed = true


func _process(delta: float) -> void:
	super._process(delta)


func _on_bounce_state_changed(value: BounceActor.BounceState) -> void:
	if value == BounceActor.BounceState.NONE:
		bounce_actor._is_ability_pressed = true
