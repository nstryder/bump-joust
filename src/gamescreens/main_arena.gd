extends Arena


# What needs to happen?
# Spawn all players
# Start timer
# Game ends when only one player is left
# Or when timer expires (do later)

# TODO: Why toggling input does not come back???
# input_direction becomes interfered...

var actor_list: Array[Actor] = []
var game_is_over: bool = false

@onready var message: Label = %Message
@onready var countdown_player: AnimationPlayer = %CountdownPlayer


func _ready() -> void:
	spawn_actors()
	super._ready()
	message.hide()
	toggle_actors_inputs(false)
	countdown_player.play("begin")
	await countdown_player.animation_finished
	toggle_actors_inputs(true)


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
	toggle_actors_inputs(false)
	await get_tree().create_timer(2.0).timeout
	Game.return_to_lobby()


func _on_actor_rung_out(actor: Actor) -> void:
	super._on_actor_rung_out(actor)
	if game_is_over:
		return
	if actor.controller == Actor.Controller.PLAYER:
		show_message("You lose...")
		stop_game()
	else:
		await get_tree().process_frame
		if actors.get_child_count() == 1:
			show_message("You win!")
			stop_game()
