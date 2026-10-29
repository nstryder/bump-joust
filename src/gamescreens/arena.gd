extends Node2D

@export var bump_sfx: AudioStream

var collided_this_frame: bool = false

@onready var actors: Node2D = %Actors


func _ready() -> void:
	for actor: Actor in actors.get_children():
		actor.collided.connect(_on_actor_collided)


func _physics_process(_delta: float) -> void:
	collided_this_frame = false


func _on_actor_collided(at: Vector2) -> void:
	if collided_this_frame:
		return
	collided_this_frame = true
	Audio.play_2d(bump_sfx, at)
	var bump_vfx := ParticleCircleBurst.construct()
	add_child(bump_vfx)
	bump_vfx.global_position = at
	bump_vfx.emitting = true
	

func _on_arena_bounds_body_exited(actor: Actor) -> void:
	actor.die()
