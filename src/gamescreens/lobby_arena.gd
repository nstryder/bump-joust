extends Arena
class_name LobbyArena


# RNG select character


# Touch stairs
# Request transition from gamemanager?
# Send over selected character 


var player: Actor

@onready var player_spawn_point: Marker2D = $PlayerSpawnPoint
@onready var dummy: Actor = $CenterPoint/Actors/Dummy
@onready var stairs: Area2D = $Stairs


func _ready() -> void:
	super._ready()
	stairs.hide()
	# roll_archetype()
	spawn_player()


func roll_archetype() -> void:
	Game.player_archetype = Game.Archetypes[Game.Archetypes.keys().pick_random()]
	print("Rolled ", Game.player_archetype)


func spawn_player() -> void:
	player = Game.instance_player()
	actors.add_child(player)
	player.global_position = player_spawn_point.global_position
	player.reset_physics_interpolation()
	spawn_shadow(player.shadow_remote)


func reveal_stairs() -> void:
	stairs.show()
	stairs.monitoring = true


func _on_actor_rung_out(actor: Actor) -> void:
	super._on_actor_rung_out(actor)
	if actor == player:
		await get_tree().create_timer(0.3).timeout
		spawn_player()
	elif actor == dummy:
		reveal_stairs()


func _on_stairs_body_entered(body: Node2D) -> void:
	if body != player: return
	Game.start_main_game()
