extends Control


@export var bgm: AudioStream


func _ready() -> void:
	Audio.play_bgm(bgm)


func _on_replay_button_pressed() -> void:
	Game.return_to_lobby()
	pass
