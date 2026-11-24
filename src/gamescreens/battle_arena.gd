extends Arena
class_name BattleArena


var actor_list: Array[Actor] = []
var game_is_over: bool = false

@onready var message: Label = %Message
@onready var countdown_player: AnimationPlayer = %CountdownPlayer
@onready var level_timer: Timer = $LevelTimer
@onready var timer_progress: ProgressBar = %TimerProgress
@onready var time_display: Label = %TimeDisplay


func _ready() -> void:
	set_process(false)
	spawn_actors()
	super._ready()
	message.hide()
	toggle_actors_inputs(false)
	start_countdown()
	await countdown_player.animation_finished
	set_process(true)
	level_timer.start()
	toggle_actors_inputs(true)


func _process(_delta: float) -> void:
	time_display.text = "Time: %.2f s" % level_timer.time_left
	timer_progress.value = level_timer.time_left / level_timer.wait_time * 100


func start_countdown() -> void:
	countdown_player.play("begin")


func spawn_actors() -> void:
	actor_list.append(Game.instance_player())
	actor_list.append_array(Game.instance_cpus())
	actor_list.shuffle()

	for i in actor_list.size():
		var actor: Actor = actor_list[i]
		actors.add_child(actor)
		actor.global_position = current_stage.get_spawn_point(i)
		actor.reset_physics_interpolation()


func show_message(text: String) -> void:
	message.text = text
	message.show()


func stop_game() -> void:
	game_is_over = true
	set_process(false)
	level_timer.stop()
	toggle_actors_inputs(false)


func is_game_won() -> bool:
	if actors.get_child_count() == 1:
		var candidate: Actor = actors.get_child(0)
		return candidate.controller == Actor.Controller.PLAYER
	return false


func win(kill_cam_position: Vector2) -> void:
	if game_is_over:
		return
	show_message("You win!")
	stop_game()
	Audio.play_2d(win_sfx, kill_cam_position)
	show_kill_cam(kill_cam_position)
	await get_tree().create_timer(2.0).timeout
	Game.advance_level()


func lose() -> void:
	if game_is_over:
		return
	show_message("You lose...")
	stop_game()
	await get_tree().create_timer(2.0).timeout
	Game.return_to_lobby()


func tie() -> void:
	if game_is_over:
		return
	show_message("Time out!")
	stop_game()
	var leftovers: Array = actors.get_children().map(func(actor: Actor) -> Game.Archetypes: return actor.archetype)
	Game.sudden_death_leftovers.assign(leftovers)
	await get_tree().create_timer(2.0).timeout
	Game.start_sudden_death()


func show_kill_cam(death_position: Vector2) -> void:
	var cam_tween := create_tween()
	cam_tween.set_trans(Tween.TRANS_CUBIC)
	var original_zoom: Vector2 = camera.zoom
	var original_position: Vector2 = camera.global_position
	cam_tween.set_ignore_time_scale(true)
	cam_tween.set_ease(Tween.EASE_OUT)
	cam_tween.tween_property(camera, "global_position", death_position, 0.2)
	cam_tween.parallel().tween_property(camera, "zoom", Vector2.ONE * 5, 0.5)
	cam_tween.tween_interval(1.0)
	cam_tween.set_ease(Tween.EASE_IN)
	cam_tween.tween_property(camera, "global_position", original_position, 0.2)
	cam_tween.parallel().tween_property(camera, "zoom", original_zoom, 0.2)


func _on_actor_rung_out(actor: Actor) -> void:
	super._on_actor_rung_out(actor)
	if game_is_over:
		return
	if actor.controller == Actor.Controller.PLAYER:
		lose()
	else:
		var killed_position: Vector2 = actor.global_position
		await get_tree().process_frame
		if is_game_won():
			win(killed_position)


func _on_level_timer_timeout() -> void:
	tie()
