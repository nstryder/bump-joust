extends TileMapLayer
class_name Stage

signal actor_rung_out(actor: Actor)

@onready var shadows: Node2D = %Shadows


func _on_arena_bounds_body_exited(body: Node2D) -> void:
	if body is Actor:
		actor_rung_out.emit(body)
