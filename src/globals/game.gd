extends Node

const LOBBY = preload("uid://bv2f5c07uby2a")
const SUDDEN_DEATH = preload("uid://c3bopdykmd1tg")

const LEVELS: Array[PackedScene] = [
	preload("res://src/gamescreens/levels/level_1.tscn"),
	preload("res://src/gamescreens/levels/level_2.tscn"),
]

const CHARGEY = preload("uid://devg3o5en8yjo")
const BOUNCY = preload("uid://bw5a4onwkgd1")
const SLIPPY = preload("uid://dw3pb2s2qtrpk")


enum Archetypes {
	CHARGEY,
	BOUNCY,
	SLIPPY,
	KILLER
}

const archetype_scenes: Dictionary[Archetypes, PackedScene] = {
	Archetypes.CHARGEY: CHARGEY,
	Archetypes.BOUNCY: BOUNCY,
	Archetypes.SLIPPY: SLIPPY
}

var player_archetype := Archetypes.CHARGEY
var is_changing_scenes: bool = false
var is_tutorial_completed: bool = false
var sudden_death_leftovers: Array[Archetypes] = []
var current_level: int = 0

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
	await get_tree().process_frame
	get_tree().current_scene.process_mode = Node.PROCESS_MODE_DISABLED
	await shroud.fade_out()
	get_tree().change_scene_to_packed(new_scene)
	await get_tree().process_frame
	get_tree().current_scene.process_mode = Node.PROCESS_MODE_DISABLED
	await shroud.fade_in()
	await get_tree().process_frame
	get_tree().current_scene.process_mode = Node.PROCESS_MODE_INHERIT
	is_changing_scenes = false


func start_new_level() -> void:
	change_scene(LEVELS[current_level])


func advance_level() -> void:
	current_level += 1
	if current_level < LEVELS.size():
		start_new_level()
	else:
		return_to_lobby()


func start_sudden_death() -> void:
	change_scene(SUDDEN_DEATH)


func return_to_lobby() -> void:
	current_level = 0
	change_scene(LOBBY)
