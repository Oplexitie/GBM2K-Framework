extends Node2D

enum CELL_TYPES{ ACTOR, OBSTACLE }
@export var type : CELL_TYPES = CELL_TYPES.ACTOR

@onready var dialogue_manager = get_node("/root/Node2D/Dialogue_Box")
