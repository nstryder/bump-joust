extends BattleArena


func spawn_actors() -> void:
	super.spawn_actors()
	# More optimized to just not spawn any actors from previous level
	# But this is funnier
	for actor: Actor in actors.get_children():
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
