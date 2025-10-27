class_name ActorGrid
extends PawnGrid

func _ready() -> void:
	initialize_cells("Tilemap", "coll_type")
	initialize_pawns(ACTOR)

func request_move(pawn: Pawn, direction: Vector2i) -> Vector2i:
	var cell: Dictionary = get_cell_data(pawn.position, direction)
	
	match cell.target_type:
		EMPTY:
			update_pawn_pos(pawn.type, cell.start, cell.target)
			return map_to_local(cell.target)
		_:
			return Vector2i.ZERO

func request_event(pawn: Pawn, direction: Vector2i) -> void:
	var cell: Dictionary = get_cell_data(pawn.position, direction)
	
	if cell.target_type == ACTOR:
		var event_pawn: Pawn = get_cell_pawn(cell.target)
		if event_pawn: event_pawn.trigger_event(direction)
