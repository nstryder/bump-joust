extends Node2D
class_name BaseCpuControl


@onready var actor: Actor = get_parent()


func _ready() -> void:
	if not actor.controller == Actor.Controller.CPU:
		queue_free()


func _process(_delta: float) -> void:
	# AI Logic will be very simple
	# Seek out closest target and ram into it
	actor.input_direction = Vector2.ZERO
	var closest_target: Actor = _get_closest_target()
	if closest_target:
		actor.input_direction = global_position.direction_to(closest_target.global_position)


func _get_closest_target() -> Actor:
	var targets: Array[Actor] = []
	targets.assign(get_tree().get_nodes_in_group("actors"))
	targets.erase(actor)
	if targets.is_empty():
		return null
	
	# Strategy:
	# Collect all distances squared
	# Map distance to actor
	# Get min distance
	# Get corresponding actor with that distance
	var distances_sq: Array = targets.map(func(x: Actor) -> float: return global_position.distance_squared_to(x.global_position))
	var distance_to_actors: Dictionary[float, Actor] = {}
	for i in targets.size():
		distance_to_actors[distances_sq[i]] = targets[i]
	
	var shortest_distance: float = distances_sq.min()
	var closest_target: Actor = distance_to_actors[shortest_distance]

	return closest_target
