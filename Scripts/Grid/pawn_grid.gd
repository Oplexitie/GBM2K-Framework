class_name PawnGrid
extends TileMapLayer

enum { EMPTY = -1, ACTOR, OBSTACLE, EVENT }

var pawn_grid: Node
var pawn_coords: Dictionary[Vector2i, Pawn]

func _init(grid: Node2D) -> void:
	_initialize_grid_data(grid)

func _initialize_grid_data(grid: Node2D) -> void:
	tile_set = load("uid://brjfac31s05jj")
	collision_enabled = false
	visible = false
	pawn_grid = grid

func initialize_cells(node_group: String, custom_data: String) -> void:
	var all_layers: Array[Node] = get_tree().get_nodes_in_group(node_group)
	for layer in all_layers:
		var used_cells: Array[Vector2i] = layer.get_used_cells_by_id()
		for cell in used_cells:
			var get_target_data: TileData = layer.get_cell_tile_data(cell)
			var cell_coll_id: int = get_target_data.get_custom_data(custom_data)
			set_cell(cell, cell_coll_id, Vector2i.ZERO)

func get_grid_region(node_group: String) -> Rect2i:
	var grid_region: Rect2i
	var curr_max_cells: int = 0
	var all_layers: Array[Node] = get_tree().get_nodes_in_group(node_group)
	for layer in all_layers:
		var layer_region: Rect2i = layer.get_used_rect()
		var cell_num: int = layer_region.get_area()
		if cell_num > curr_max_cells:
			grid_region = layer_region
			curr_max_cells = cell_num
	return grid_region

func initialize_pawns(pawn_type: int) -> void:
	for child in pawn_grid.get_children():
		if child.type == pawn_type:
			var child_map_pos: Vector2i = local_to_map(child.position)
			set_cell(child_map_pos, child.type, Vector2i.ZERO)
			pawn_coords[child_map_pos] = child

func get_cell_data(start: Vector2i, direction: Vector2i) -> Dictionary:
	var cell_start: Vector2i = local_to_map(start)
	var cell_target: Vector2i = cell_start + direction
	var cell_target_type: int = get_cell_source_id(cell_target)
	
	return { 'start': cell_start, 'target': cell_target, 'target_type': cell_target_type }

func get_cell_pawn(coordinates: Vector2i) -> Pawn:
	if pawn_coords.has(coordinates):
		return pawn_coords[coordinates] # If a Pawn has those coordinates
	
	return # No Pawn

func update_pawn_pos(pawn_type: int, cell_start: Vector2i, cell_target: Vector2i) -> void:
	set_cell(cell_target, pawn_type, Vector2i.ZERO)
	set_cell(cell_start, EMPTY, Vector2i.ZERO)
	
	# Avoids adding obstacles to pawn_coords
	if pawn_coords.has(cell_start):
		pawn_coords[cell_target] = pawn_coords[cell_start]
		pawn_coords.erase(cell_start)
