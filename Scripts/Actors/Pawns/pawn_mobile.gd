extends Pawn
class_name PawnMobile

@export var speed: float = 1.5

var move_tween: Tween
var switch_walk: bool = false
var is_moving: bool = false
var is_talking: bool = false
var is_stopped: bool = false

@onready var animtree: AnimationTree =  $AnimationTree
@onready var walk_anim_length: float = $AnimationPlayer.get_animation("walk_down").length
@onready var Grid: Node2D = get_parent()

func can_move() -> bool:
	return not is_moving and not is_talking and not is_stopped

func set_anim_direction(input_direction: Vector2i):
	animtree.set("parameters/StateMachine/Idle/blend_position", input_direction)
	animtree.set("parameters/StateMachine/Walk1/blend_position", input_direction)
	animtree.set("parameters/StateMachine/Walk0/blend_position", input_direction)

func move_to(target_position: Vector2):
	# Takes care of Animation Speed + Leg Switching (each step, the character swithes the leg they use)
	animtree.set("parameters/TimeScale/scale", speed)
	animtree["parameters/StateMachine/playback"].start("Walk1" if switch_walk else "Walk0")
	animtree.advance(0)
	
	# Moves the character at the speed of the animation (which can be modified with the speed variable)
	move_tween = create_tween()
	move_tween.connect("finished", _move_tween_done)
	move_tween.tween_property(self, "position", target_position, walk_anim_length/speed)
	is_moving = true

func _move_tween_done():
	move_tween.kill()
	switch_walk = !switch_walk
	is_moving = false

func set_talking(talk_state: bool):
	is_talking = !talk_state
