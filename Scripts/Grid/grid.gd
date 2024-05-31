extends TileMap

enum { EMPTY = -1, ACTOR, OBSTACLE }

func _ready():
	# Adds the Collision Tiles
	for child in get_children():
		set_cellv(world_to_map(child.position), child.type)
	
	# Makes all the Collision Tiles Invisible
	for n in 2:
		tile_set.tile_set_modulate(n,0)
	
# Can be used to get a specific pawn in the Grid
func get_cell_pawn(coordinates):
	for node in get_children():
		if world_to_map(node.position) == coordinates:
			return(node)

# Used to request movement opportunity
func request_move(pawn, direction):
	var cell_start : Vector2 = world_to_map(pawn.position)
	var cell_target : Vector2 = cell_start + direction
	
	var cell_target_type = get_cellv(cell_target)
	match cell_target_type:
		EMPTY:
			return update_pawn_position(pawn, cell_start, cell_target)

# Used to request dialogue opportunity
func request_diag(pawn, direction):
	var cell_start : Vector2 = world_to_map(pawn.position)
	var cell_target : Vector2 = cell_start + direction
	
	var cell_target_type = get_cellv(cell_target)
	match cell_target_type:
		ACTOR:
			var object_pawn = get_cell_pawn(cell_target)
			# Checks just in case if the pawn was detected corretly
			if object_pawn:
				object_pawn.trigger_event(direction)

# Updates the pawn's collision tiles and position
func update_pawn_position(pawn, cell_start, cell_target):
	set_cellv(cell_target, pawn.type)
	set_cellv(cell_start, EMPTY)
	return map_to_world(cell_target) + cell_size / 2
