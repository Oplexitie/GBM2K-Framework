extends Node2D
class_name Pawn

enum CELL_TYPES{ ACTOR, OBSTACLE }
export(CELL_TYPES) var type = CELL_TYPES.ACTOR

onready var dialogue_manager = get_node("/root/Node2D/Dialogue_Box")
