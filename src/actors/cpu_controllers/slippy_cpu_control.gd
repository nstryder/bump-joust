extends BaseCpuControl


@onready var slip_actor: SlipActor = actor


func _ready() -> void:
	super._ready()
	slip_actor.slip_state_changed.connect(_on_slip_state_changed)
	slip_actor._is_ability_pressed = true


func _process(delta: float) -> void:
	super._process(delta)


func _on_slip_state_changed(value: SlipActor.SlipState) -> void:
	if value == SlipActor.SlipState.NONE:
		slip_actor._is_ability_pressed = true
