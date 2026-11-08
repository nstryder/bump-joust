extends Node2D
class_name Arena

const BOUNCY = preload("uid://bw5a4onwkgd1")
const CHARGEY = preload("uid://devg3o5en8yjo")
const SLIPPY = preload("uid://dw3pb2s2qtrpk")

@export var bump_sfx: AudioStream
@export var bump_intensity: float = 1.0
@export var bump_min_intensity: float = 400
@export var hitstop_curve: Curve

## Inversely proportional to how much hitstop should occur. Needed since we set hitstop dynamically.
@export var hitstop_resistance: float = 2500

var collided_this_frame: bool = false

var tween: Tween

@onready var actors: Node2D = %Actors
@onready var stage_holder: Node2D = $StageHolder
@onready var current_stage: Stage = stage_holder.get_child(0)


func _ready() -> void:
	setup_all_signals()
	spawn_all_shadows()


func setup_all_signals() -> void:
	EventBus.hitstop_requested.connect(do_hitstop)
	current_stage.actor_rung_out.connect(_on_actor_rung_out)


func spawn_all_shadows() -> void:
	for actor: Actor in actors.get_children():
		actor.collided.connect(_on_actor_collided)
		var shadow: Shadow = spawn_shadow(actor.shadow_remote)
		actor.shadow = shadow


func spawn_shadow(remote_transform: RemoteTransform2D) -> Shadow:
	var shadow := Shadow.construct()
	current_stage.shadows.add_child(shadow)
	var path_to: NodePath = remote_transform.get_path_to(shadow)
	remote_transform.remote_path = path_to
	shadow.reset_physics_interpolation()
	return shadow

		
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


func _on_actor_collided(actor1: Actor, state1: PhysicsDirectBodyState2D, actor2: Actor, state2: PhysicsDirectBodyState2D) -> void:
	if collided_this_frame:
		return
	collided_this_frame = true
	reset_collide_flag()
	for i in state1.get_contact_count():
		var collided_at: Vector2 = state1.get_contact_collider_position(i)

		# Determine max speed for various calculations
		var speed1: float = state1.get_contact_local_velocity_at_position(i).length()
		var speed2: float = state2.get_contact_local_velocity_at_position(i).length()
		# var highest_speed: float = maxf(speed1, speed2)
		var highest_speed: float = speed1 + speed2

		# Determine final bump instensity, used for both sides 
		var final_bump_intensity: float = bump_intensity * highest_speed
		print(final_bump_intensity)
		final_bump_intensity = maxf(final_bump_intensity, bump_min_intensity)

		# Apply mutual bump force
		var bump_normal1: Vector2 = state1.get_contact_local_normal(i)
		var bump_normal2: Vector2 = state2.get_contact_local_normal(i)
		var bump_force1: float = final_bump_intensity * actor1.knockback_take_modifier * actor2.knockback_give_modifier
		var bump_force2: float = final_bump_intensity * actor2.knockback_take_modifier * actor1.knockback_give_modifier
		state1.apply_central_impulse(bump_normal1 * bump_force1)
		state2.apply_central_impulse(bump_normal2 * bump_force2)
		
		# Play sfx
		Audio.play_2d(bump_sfx, collided_at)

		# Show hitsparks
		var bump_vfx := ParticleCircleBurst.construct()
		add_child(bump_vfx)
		bump_vfx.global_position = collided_at
		bump_vfx.emitting = true

		# Determine hitstop based on intensity of collision
		var max_bump_force: float = maxf(bump_force1, bump_force2)
		var hitstop_time: float = max_bump_force / hitstop_resistance

		print("%.3f | %.3f" % [max_bump_force, hitstop_time])
		do_hitstop(hitstop_time)
	

func _on_actor_rung_out(actor: Actor) -> void:
	if Game.is_changing_scenes:
		return
	actor.die()
	do_hitstop(1.0)
