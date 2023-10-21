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
	var cell_start = world_to_map(pawn.position)
	var cell_target = cell_start + direction
	
	var cell_target_type = get_cellv(cell_target)
	match cell_target_type:
		EMPTY:
			return update_pawn_position(pawn, cell_start, cell_target)

# Updates the pawn's collision tiles and position
func update_pawn_position(pawn, cell_start, cell_target):
	set_cellv(cell_target, pawn.type)
	set_cellv(cell_start, EMPTY)
	return map_to_world(cell_target) + cell_size / 2
