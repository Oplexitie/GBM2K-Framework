class_name EventGrid
extends PawnGrid

func _ready() -> void:
	initialize_pawns(EVENT)

func request_event(pawn: Pawn, direction: Vector2i) -> void:
	var cell: Dictionary = get_cell_data(pawn.position, direction)
	
	var event_pawn: Pawn = get_cell_pawn(cell.target)
	if event_pawn: event_pawn.trigger_event()
