extends BaseCpuControl


# Moves straight at enemy
# Every 4 seconds, do charge attack

@export var charge_interval: float = 4.0

@onready var charge_actor: ChargeActor = actor
@onready var charge_duration: Timer = $ChargeDuration
@onready var charge_interval_timer: Timer = $ChargeAttackInterval


func _ready() -> void:
	super._ready()
	charge_interval_timer.wait_time = charge_interval


func _on_charge_attack_interval_timeout() -> void:
	charge_actor.is_charging_pressed = true
	charge_actor.is_charging_just_pressed = true
	charge_duration.start(charge_actor.charge_startup_time + 0.5)


func _on_charge_duration_timeout() -> void:
	charge_actor.is_charging_pressed = false
	charge_actor.is_charging_just_pressed = false
	charge_actor.is_charging_released = true
