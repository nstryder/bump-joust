extends Area2D
class_name LandingForce


@export var pushing_force: float = 1000

var _user: Actor

const SELF_SCENE = preload("uid://b2torbiqiacen")


static func construct(user: Actor) -> LandingForce:
	var instance: LandingForce = SELF_SCENE.instantiate()
	instance._user = user
	return instance


func _ready() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is not RigidBody2D or body == _user:
		return
	
	var rigid_body: RigidBody2D = body
	var pushing_direction: Vector2 = global_position.direction_to(rigid_body.global_position)
	rigid_body.apply_central_impulse(pushing_direction * pushing_force)
