extends TileMap

enum { EMPTY = -1, ACTOR, OBSTACLE }

func _ready():
	# Adds the Collision Tiles
	for child in get_children():
		set_cell(0, local_to_map(child.position), child.type, Vector2i.ZERO)
	
	set_layer_modulate(0, Color(0,0,0,0))

# Can be used to get a specific pawn in the Grid
func get_cell_pawn(coordinates : Vector2i):
	for node in get_children():
		if local_to_map(node.position) == coordinates:
			return(node)

# Used to request movement opportunity
func request_move(pawn : Node2D, direction : Vector2):
	var cell_start : Vector2 = local_to_map(pawn.position)
	var cell_target : Vector2 = cell_start + direction
	
	var cell_target_type = get_cell_source_id(0,cell_target)
	match cell_target_type:
		EMPTY:
			return update_pawn_position(pawn, cell_start, cell_target)

# Used to request dialogue opportunity
func request_diag(pawn : Node2D, direction : Vector2):
	var cell_start : Vector2 = local_to_map(pawn.position)
	var cell_target : Vector2 = cell_start + direction
	
	var cell_target_type = get_cell_source_id(0,cell_target)
	match cell_target_type:
		ACTOR:
			var object_pawn = get_cell_pawn(cell_target)
			# Checks just in case if the pawn was detected corretly
			if object_pawn:
				object_pawn.trigger_event(direction)

# Updates the pawn's collision tiles and position
func update_pawn_position(pawn : Node2D, cell_start : Vector2, cell_target : Vector2):
	set_cell(0, cell_target, pawn.type, Vector2i.ZERO)
	set_cell(0, cell_start, EMPTY, Vector2i.ZERO)
	return map_to_local(cell_target)
