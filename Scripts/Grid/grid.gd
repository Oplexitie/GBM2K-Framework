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
	for u in all_layers:
		var used_cells: Array[Vector2i] = u.get_used_cells_by_id()
		for i in used_cells:
			var get_target_data: TileData = u.get_cell_tile_data(i)
			var cell_coll_id: int = get_target_data.get_custom_data("coll_type")
			actor_grid.set_cell(i, cell_coll_id, Vector2i.ZERO)
	
	# Adds the collision to Pawns
	for child in get_children():
		match child.type:
			EVENT:
				event_grid.set_cell(event_grid.local_to_map(child.position), child.type, Vector2i.ZERO)
			_:
				actor_grid.set_cell(actor_grid.local_to_map(child.position), child.type, Vector2i.ZERO)

func request_move(pawn: Pawn, direction: Vector2i) -> Vector2i:
	var cell_start: Vector2i = actor_grid.local_to_map(pawn.position)
	var cell_target: Vector2i = cell_start + direction
	
	var cell_target_type: int = actor_grid.get_cell_source_id(cell_target)
	match cell_target_type:
		EMPTY:
			# If cell_target is empty move the pawn there
			return update_pawn_position(pawn, cell_start, cell_target)
		_:
			return Vector2i.ZERO

func request_event(pawn: Pawn):
	var cell_target: Vector2i = event_grid.local_to_map(pawn.position)
	
	var cell_target_type: int = event_grid.get_cell_source_id(cell_target)
	if cell_target_type == EVENT:
		var event_pawn: Pawn = get_cell_pawn(cell_target, EVENT)
		# Checks just in case if the pawn was detected corretly
		if event_pawn:
			event_pawn.trigger_event()

func request_dial(pawn: Pawn, direction: Vector2i):
	var cell_start: Vector2i = actor_grid.local_to_map(pawn.position)
	var cell_target: Vector2i = cell_start + direction
	
	var cell_target_type: int = actor_grid.get_cell_source_id(cell_target)
	match cell_target_type:
		ACTOR:
			var actor_pawn: Pawn = get_cell_pawn(cell_target, ACTOR)
			# Checks just in case if the pawn was detected corretly
			if actor_pawn:
				actor_pawn.trigger_event(direction)

func get_cell_pawn(coordinates: Vector2i, pawn_type: int) -> Pawn:
	# Loops through all Pawns
	for node in get_children():
		# Skips a loop, if node isn't the pawn type we're looking for
		if node.type != pawn_type: continue
		
		# Gets the right grid to search for the pawn we're looking for
		var get_grid: TileMapLayer = actor_grid if pawn_type != EVENT else event_grid
		if get_grid.local_to_map(node.position) == coordinates:
			return node # Return pawn found at coordinates
	
	return # Return nothing if no pawn was found at coordinates

# Updates the pawn's collision tiles and position
func update_pawn_position(pawn: Pawn, cell_start: Vector2i, cell_target: Vector2i) -> Vector2i:
	actor_grid.set_cell(cell_target, pawn.type, Vector2i.ZERO)
	actor_grid.set_cell(cell_start, EMPTY, Vector2i.ZERO)
	return actor_grid.map_to_local(cell_target)
