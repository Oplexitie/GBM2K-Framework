extends TileMap

enum { EMPTY = -1, ACTOR, OBSTACLE }

func _ready():
	# Adds collision to tiles
	add_coll_tiles([1,2])
	
	# Adds the collision to Actors
	for child in get_children():
		set_cell(0, local_to_map(child.position), child.type, Vector2i.ZERO)
	
	set_layer_modulate(0, Color.TRANSPARENT)

# Used to add collision to tiles using custom data
func add_coll_tiles(layers: Array[int]):
	for u in layers:
		var used_cells: Array[Vector2i] = get_used_cells_by_id(u)
		for i in used_cells:
			var get_target_data: TileData = get_cell_tile_data(u,i)
			var cell_coll_id: int = get_target_data.get_custom_data("coll_type")
			set_cell(0, i, cell_coll_id, Vector2i.ZERO)

# Used to request movement opportunity
func request_move(pawn: Node2D, direction: Vector2i) -> Vector2i:
	var cell_start: Vector2i = local_to_map(pawn.position)
	var cell_target: Vector2i = cell_start + direction
	
	var cell_target_type: int = get_cell_source_id(0,cell_target)
	match cell_target_type:
		EMPTY:
			return update_pawn_position(pawn, cell_start, cell_target)
		_:
			return Vector2i.ZERO

# Used to request dialogue opportunity
func request_diag(pawn: Node2D, direction: Vector2i):
	var cell_start: Vector2i = local_to_map(pawn.position)
	var cell_target: Vector2i = cell_start + direction
	
	var cell_target_type: int = get_cell_source_id(0,cell_target)
	match cell_target_type:
		ACTOR:
			var object_pawn: Pawn = get_cell_pawn(cell_target)
			# Checks just in case if the pawn was detected corretly
			if object_pawn:
				object_pawn.trigger_event(direction)

# Can be used to get a specific pawn in the Grid
func get_cell_pawn(coordinates: Vector2i):
	for node in get_children():
		if local_to_map(node.position) == coordinates:
			return(node)

# Updates the pawn's collision tiles and position
func update_pawn_position(pawn: Node2D, cell_start: Vector2i, cell_target: Vector2i) -> Vector2i:
	set_cell(0, cell_target, pawn.type, Vector2i.ZERO)
	set_cell(0, cell_start, EMPTY, Vector2i.ZERO)
	return map_to_local(cell_target)
