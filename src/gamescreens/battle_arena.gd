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


func toggle_actors_inputs(value: bool) -> void:
	print("Toggling input to ", value)
	for actor: Actor in actors.get_children():
		actor.is_input_enabled = value


func stop_game() -> void:
	game_is_over = true
	set_process(false)
	level_timer.stop()
	toggle_actors_inputs(false)
	await get_tree().create_timer(2.0).timeout
	Game.return_to_lobby()


func check_victory() -> void:
	if actors.get_child_count() == 1:
		var candidate: Actor = actors.get_child(0)
		if candidate.controller == Actor.Controller.PLAYER:
			show_message("You win!")
			stop_game()


func _on_actor_rung_out(actor: Actor) -> void:
	super._on_actor_rung_out(actor)
	if game_is_over:
		return
	if actor.controller == Actor.Controller.PLAYER:
		show_message("You lose...")
		stop_game()
	else:
		await get_tree().process_frame
		check_victory()

func _on_level_timer_timeout() -> void:
	game_is_over = true
	var leftovers: Array = actors.get_children().map(func(actor: Actor) -> Game.Archetypes: return actor.archetype)
	Game.sudden_death_leftovers.assign(leftovers)
	set_process(false)
	toggle_actors_inputs(false)
	show_message("Time out!")
	await get_tree().create_timer(2.0).timeout
	Game.start_sudden_death()
