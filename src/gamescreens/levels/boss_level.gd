extends BattleArena


func _ready() -> void:
	super._ready()
	Audio.bgm.stop()
	Audio.bgm.stream = null
	await countdown_player.animation_finished
	Audio.play_bgm(bgm)


func spawn_actors() -> void:
	var actor: Actor = Game.instance_player()
	actors.add_child(actor)
	actor.global_position = current_stage.get_spawn_point(0)
	actor.reset_physics_interpolation()


func tie() -> void:
	lose()
	show_message("Could not beat the boss in time...")
