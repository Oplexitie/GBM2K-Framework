extends Node2D

enum CELL_TYPES{ ACTOR, OBSTACLE }
@export var type: CELL_TYPES = CELL_TYPES.ACTOR

@onready var dialogue_manager: Node2D = get_node("/root/Node2D/Dialogue_Box")
