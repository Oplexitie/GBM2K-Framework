extends Node2D

enum { EMPTY = -1, ACTOR, OBSTACLE, EVENT }

@export var actor_grid: TileMapLayer
@export var event_grid: TileMapLayer

func _ready():
	init_collision()

func init_collision():
	# Gets tilemap layers
	var all_layers: Array[Node]
	for layer in get_parent().get_children():
		if layer is TileMapLayer: all_layers.append(layer)
	
	# Adds collision to tiles using custom data
	for layer in all_layers:
		var used_cells: Array[Vector2i] = layer.get_used_cells_by_id()
		for cell in used_cells:
			var get_target_data: TileData = layer.get_cell_tile_data(cell)
			var cell_coll_id: int = get_target_data.get_custom_data("coll_type")
			actor_grid.set_cell(cell, cell_coll_id, Vector2i.ZERO)
	
	# Adds the collision to Pawns
	for child in get_children():
		var grid_type: TileMapLayer = actor_grid if child.type != EVENT else event_grid
		grid_type.set_cell(event_grid.local_to_map(child.position), child.type, Vector2i.ZERO)

func get_cell_data(start: Vector2i, direction: Vector2i, grid_type: int) -> Dictionary:
	var cell_start: Vector2i = actor_grid.local_to_map(start)
	var cell_target: Vector2i = cell_start + direction
	
	var layer_type: TileMapLayer = actor_grid if grid_type != EVENT else event_grid
	var cell_target_type: int = layer_type.get_cell_source_id(cell_target)
	
	return { 'start': cell_start, 'target': cell_target, 'target_type': cell_target_type }

func request_move(pawn: Pawn, direction: Vector2i) -> Vector2i:
	var cell: Dictionary = get_cell_data(pawn.position, direction, ACTOR)
	
	match cell.target_type:
		EMPTY:
			return update_pawn_position(pawn.type, cell.start, cell.target)
		_:
			return Vector2i.ZERO

func request_event(pawn: Pawn, direction: Vector2i, request_type: int):
	var cell: Dictionary = get_cell_data(pawn.position, direction, request_type)

	match cell.target_type:
		ACTOR:
			var event_pawn: Pawn = get_cell_pawn(cell.target, ACTOR, actor_grid)
			if event_pawn: event_pawn.trigger_event(direction)
		EVENT:
			var event_pawn: Pawn = get_cell_pawn(cell.target, EVENT, event_grid)
			if event_pawn: event_pawn.trigger_event()

func get_cell_pawn(coordinates: Vector2i, pawn_type: int, grid_type: TileMapLayer) -> Pawn:
	for pawn in get_children():
		if pawn.type != pawn_type: continue # Skips a loop, if node isn't the right type
		
		if grid_type.local_to_map(pawn.position) == coordinates:
			return pawn # If pawn was found at coordinates
	
	return # No Pawn

func update_pawn_position(pawn_type: int, cell_start: Vector2i, cell_target: Vector2i) -> Vector2i:
	actor_grid.set_cell(cell_target, pawn_type, Vector2i.ZERO)
	actor_grid.set_cell(cell_start, EMPTY, Vector2i.ZERO)
	return actor_grid.map_to_local(cell_target)
