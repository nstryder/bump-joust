extends Area2D
class_name GoopTileArea


const SELF_SCENE = preload("uid://cm1uokma5x2ff")

var _can_paralyze: bool = false

@onready var timer: Timer = $Timer

static func construct(damping: float, can_paralyze: bool) -> GoopTileArea:
	var instance: GoopTileArea = SELF_SCENE.instantiate()
	instance.linear_damp = damping
	instance._can_paralyze = can_paralyze
	return instance


func _on_body_entered(body: Node2D) -> void:
	if not (_can_paralyze and body is Actor):
		return
	var actor: Actor = body
	actor.is_input_enabled = false
	

func _on_body_exited(body: Node2D) -> void:
	if not (_can_paralyze and body is Actor):
		return
	var actor: Actor = body
	actor.is_input_enabled = true


func _on_tree_exiting() -> void:
	for body: Node2D in get_overlapping_bodies():
		if not (_can_paralyze and body is Actor):
			continue
		var actor: Actor = body
		actor.is_input_enabled = true
