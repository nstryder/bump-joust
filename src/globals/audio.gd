extends Node


func play_2d(stream: AudioStream, position: Vector2) -> void:
	var player := AudioStreamPlayer2D.new()
	player.global_position = position
	player.stream = stream
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)
	player.bus = "SFX"
