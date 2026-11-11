extends TileMapLayer
class_name Stage

signal actor_rung_out(actor: Actor)

@onready var shadows: Node2D = %Shadows
@onready var spawn_points: Node2D = $SpawnPoints
@onready var arena_collision_polygon: CollisionPolygon2D = %ArenaCollisionPolygon
@onready var arena_mask: Polygon2D = %ArenaMask


func get_spawn_point(index: int) -> Vector2:
	var marker: Marker2D = spawn_points.get_child(index)
	return marker.global_position


func _on_arena_bounds_body_exited(body: Node2D) -> void:
	if body is Actor:
		actor_rung_out.emit(body)
