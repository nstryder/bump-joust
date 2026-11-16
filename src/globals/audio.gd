extends Node2D

@onready var bgm: AudioStreamPlayer = $BGM

func play_bgm(stream: AudioStream) -> void:
	if bgm.stream == stream:
		return
	bgm.stream = stream
	bgm.play()


func play_2d(stream: AudioStream, spawn_position: Vector2) -> void:
	var player := AudioStreamPlayer2D.new()
	player.global_position = spawn_position
	player.stream = stream
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)
	player.bus = "SFX"
