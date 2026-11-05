extends Area2D
class_name LandingForce

const SELF_SCENE = preload("uid://b2torbiqiacen")

@export var pushing_force: float = 1000
@export var radius: float = 32


var _user: Actor

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var collision_circle: CircleShape2D = collision_shape_2d.shape
@onready var circle: Sprite2D = $Circle


static func construct(user: Actor, pushing_force_mod: float, radius_mod: float) -> LandingForce:
	var instance: LandingForce = SELF_SCENE.instantiate()
	instance._user = user
	instance.pushing_force *= pushing_force_mod
	instance.radius *= radius_mod
	return instance


func _ready() -> void:
	collision_circle.radius = radius
	var sprite_width: float = circle.texture.get_size().x
	circle.scale *= radius / sprite_width * 2
	await get_tree().physics_frame
	await get_tree().physics_frame
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is not RigidBody2D or body == _user:
		return
	
	var rigid_body: RigidBody2D = body
	var pushing_direction: Vector2 = global_position.direction_to(rigid_body.global_position)
	rigid_body.apply_central_impulse(pushing_direction * pushing_force)
	EventBus.hitstop_requested.emit(0.3)
