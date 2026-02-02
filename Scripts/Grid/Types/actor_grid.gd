class_name ActorGrid
extends PawnGrid

var astar: AStarGrid2D = AStarGrid2D.new()

func _ready() -> void:
	initialize_cells("Tilemap", "coll_type")
	initialize_pawns(ACTOR)
	_initialize_astar()

func _initialize_astar() -> void:
	astar.region = get_grid_region("Tilemap")
	astar.cell_size = tile_set.tile_size
	astar.offset = tile_set.tile_size / 2.0
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()

func request_move(pawn: Pawn, direction: Vector2i) -> Vector2i:
	var cell: Dictionary = get_cell_data(pawn.position, direction)
	
	match cell.target_type:
		EMPTY:
			update_pawn_pos(pawn.type, cell.start, cell.target)
			return map_to_local(cell.target)
		_:
			return Vector2i.ZERO

func _id_to_dir_path(cell_path: PackedVector2Array) -> Array[Vector2i]:
	var path_moves: Array[Vector2i]
	for i in range(cell_path.size() - 1):
		path_moves.append(cell_path[i+1] - cell_path[i])
	return path_moves

func get_move_path(pawn: Pawn, end_cell: Vector2i) -> Array[Vector2i]:
	_update_astar_grid()
	
	var start_point: Vector2i = local_to_map(pawn.position)
	astar.set_point_solid(start_point, false)
	astar.set_point_solid(end_cell, false)
	
	var path: PackedVector2Array = astar.get_id_path(start_point, end_cell)
	var path_moves: Array[Vector2i] = _id_to_dir_path(path)
	return path_moves

func request_event(pawn: Pawn, direction: Vector2i) -> void:
	var cell: Dictionary = get_cell_data(pawn.position, direction)
	
	if cell.target_type == ACTOR:
		var event_pawn: Pawn = get_cell_pawn(cell.target)
		if event_pawn: event_pawn.trigger_event(direction)

func _update_astar_grid() -> void:
	for pos in get_used_cells():
		astar.set_point_solid(pos)
