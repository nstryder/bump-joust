extends Node

const LOBBY = preload("uid://bv2f5c07uby2a")
const MAIN_ARENA = preload("uid://dpdq1iv6nrbtw")


const CHARGEY = preload("uid://devg3o5en8yjo")
const BOUNCY = preload("uid://bw5a4onwkgd1")
const SLIPPY = preload("uid://dw3pb2s2qtrpk")


enum Archetypes {
	CHARGEY,
	BOUNCY,
	SLIPPY
}

const archetype_scenes: Dictionary[Archetypes, PackedScene] = {
	Archetypes.CHARGEY: CHARGEY,
	Archetypes.BOUNCY: BOUNCY,
	Archetypes.SLIPPY: SLIPPY
}

var player_archetype := Archetypes.CHARGEY
var is_changing_scenes: bool = false

@onready var shroud: ShroudGlobal = Shroud


func instance_player() -> Actor:
	var player: Actor = archetype_scenes[player_archetype].instantiate()
	player.controller = Actor.Controller.PLAYER
	return player


func instance_cpus() -> Array[Actor]:
	var actors: Array[Actor] = []
	for arch in archetype_scenes:
		if arch == player_archetype:
			continue
		var actor_instance: Actor = archetype_scenes[arch].instantiate()
		actor_instance.controller = Actor.Controller.CPU
		actors.push_back(actor_instance)
	return actors


func change_scene(new_scene: PackedScene) -> void:
	is_changing_scenes = true
	get_tree().current_scene.process_mode = Node.PROCESS_MODE_DISABLED
	await shroud.fade_out()
	await get_tree().process_frame
	get_tree().change_scene_to_packed(new_scene)
	await get_tree().process_frame
	get_tree().current_scene.process_mode = Node.PROCESS_MODE_DISABLED
	await shroud.fade_in()
	get_tree().current_scene.process_mode = Node.PROCESS_MODE_INHERIT
	is_changing_scenes = false


func start_main_game() -> void:
	change_scene(MAIN_ARENA)


func return_to_lobby() -> void:
	change_scene(LOBBY)
