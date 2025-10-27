class_name Character
extends Pawn

@export var speed: float = 1.5

var move_tween: Tween
var is_moving: bool = false
var is_talking: bool = false

@onready var chara_skin: Sprite2D = $Skin
@onready var Grid: Node2D = get_parent()

func can_move() -> bool:
	return not is_moving and not is_talking

func move_to(target_position: Vector2) -> void:
	chara_skin.set_animation_speed(speed)
	chara_skin.play_walk_animation()
	
	move_tween = create_tween()
	move_tween.connect("finished", _move_tween_done)
	move_tween.tween_property(self, "position", target_position, chara_skin.walk_length/speed)
	is_moving = true

func _move_tween_done() -> void:
	move_tween.kill()
	chara_skin.toggle_walk_side()
	is_moving = false

func set_talking(talk_state: bool) -> void:
	is_talking = talk_state
