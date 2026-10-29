extends AnimatedSprite2D
class_name Explosion


const SELF_SCENE = preload("uid://tkjnuj4funj3")


static func construct() -> Explosion:
	return SELF_SCENE.instantiate()


func _on_animation_finished() -> void:
	queue_free()
