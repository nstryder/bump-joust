extends Area2D
class_name SlipPuddle

const SELF_SCENE = preload("uid://cwj4ibw16vuke")

@onready var timer: Timer = $Timer


static func construct() -> SlipPuddle:
	return SELF_SCENE.instantiate()


func _on_timer_timeout() -> void:
	queue_free()
