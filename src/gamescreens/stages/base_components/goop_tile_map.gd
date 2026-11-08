extends TileMapLayer


var slip_actor: SlipActor
var tracked_tiles: Dictionary[Vector2, GoopTileArea] = {}

func _ready() -> void:
	EventBus.slippy_spawned.connect(_on_slippy_spawned)
	set_process(false)
	
	
func _process(_delta: float) -> void:
	if not slip_actor.slip_state == SlipActor.SlipState.ACTIVE:
		return
	var actor_pos: Vector2 = slip_actor.global_position
	var map_coord: Vector2 = local_to_map(to_local(actor_pos))
	if map_coord not in tracked_tiles:
		add_tracked_tile(map_coord)
	tracked_tiles[map_coord].timer.start(slip_actor.slip_lifetime)


func add_tracked_tile(tile_coord: Vector2) -> void:
	var goop := GoopTileArea.construct(slip_actor.slip_damping, slip_actor.slip_can_paralyze)
	tracked_tiles[tile_coord] = goop
	add_child(goop)
	goop.global_position = to_global(map_to_local(tile_coord))
	goop.timer.timeout.connect(_on_goop_timer_timeout.bind(tile_coord))
	set_cells_terrain_connect(tracked_tiles.keys(), 0, 0)


func remove_tracked_tile(tile_coord: Vector2) -> void:
	tracked_tiles[tile_coord].queue_free()
	tracked_tiles.erase(tile_coord)
	erase_cell(tile_coord)


func _on_slippy_spawned(actor: SlipActor) -> void:
	slip_actor = actor
	slip_actor.tree_exiting.connect(set_process.bind(false))
	set_process(true)


func _on_goop_timer_timeout(tile_coord: Vector2) -> void:
	remove_tracked_tile(tile_coord)
