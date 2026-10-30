extends Node2D

@export var bump_sfx: AudioStream
@export var hitstop_curve: Curve

## Proportional to how much hitstop should occur. Needed since we set hitstop dynamically.
@export var hitstop_resistance: float = 2000

var collided_this_frame: bool = false

var tween: Tween

@onready var actors: Node2D = %Actors


func _ready() -> void:
	for actor: Actor in actors.get_children():
		actor.collided.connect(_on_actor_collided)


func do_hitstop(duration: float) -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_ignore_time_scale(true)
	# sample_baked returns y for input x (0.0 to 1.0)
	# so we need to constantly feed it a value that goes from 0 to 1 (time)
	# and use that output as our engine timescale
	tween.tween_method(_interpolate_hitstop, 0, 1, duration)


func reset_collide_flag() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	collided_this_frame = false


func _interpolate_hitstop(curve_x: float) -> void:
	Engine.time_scale = hitstop_curve.sample_baked(curve_x)


func _on_actor_collided(state1: PhysicsDirectBodyState2D, state2: PhysicsDirectBodyState2D) -> void:
	if collided_this_frame:
		return
	collided_this_frame = true
	reset_collide_flag()
	for i in state1.get_contact_count():
		var collided_at: Vector2 = state1.get_contact_collider_position(i)
		
		# Play sfx
		Audio.play_2d(bump_sfx, collided_at)

		# Show hitsparks
		var bump_vfx := ParticleCircleBurst.construct()
		add_child(bump_vfx)
		bump_vfx.global_position = collided_at
		bump_vfx.emitting = true

		# Determine hitstop based on intensity of collision
		var speed1: float = state1.get_contact_local_velocity_at_position(i).length()
		var speed2: float = state2.get_contact_local_velocity_at_position(i).length()
		var highest_speed: float = maxf(speed1, speed2)
		var hitstop_time: float = highest_speed / hitstop_resistance

		print("%.2f" % hitstop_time)
		do_hitstop(hitstop_time)
	

func _on_arena_bounds_body_exited(actor: Actor) -> void:
	actor.die()
