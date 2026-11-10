extends BattleArena

#TODO: Bring only survivors into here


func spawn_actors() -> void:
	actor_list.append(Game.instance_player())
	actor_list.append_array(Game.instance_cpus())
	actor_list.shuffle()

	for i in actor_list.size():
		var actor: Actor = actor_list[i]
		actors.add_child(actor)
		actor.global_position = current_stage.get_spawn_point(i)
		actor.reset_physics_interpolation()
		if actor.archetype not in Game.sudden_death_leftovers:
			actor.die.call_deferred()

func start_countdown() -> void:
	countdown_player.play("sudden_death")


func check_victory() -> void:
	if actors.get_child_count() == 2:
		var player_survived: bool = actors.get_children().any(func(actor: Actor) -> bool: return actor.controller == Actor.Controller.PLAYER)
		if player_survived:
			show_message("You win!")
			stop_game()
