@abstract
class_name Pawn
extends Node2D

enum CELL_TYPES{ ACTOR, OBSTACLE, EVENT }
@export var type: CELL_TYPES = CELL_TYPES.ACTOR
