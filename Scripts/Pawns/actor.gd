extends "pawn.gd"

export var speed : float = 1.5
export (Array, Vector2) var move_pattern

var move_step : int = 0
var move_max : int = 0
var is_moving : bool = false
var switch_walk : bool = false

onready var Grid : TileMap = get_parent()
onready var animtree : AnimationTree =  $AnimationTree
onready var move_tween = $Tween
onready var walk_anim_length : float = $AnimationPlayer.get_animation("walk_down").length

func _ready():
	move_max = move_pattern.size()

func _process(_delta):
	if is_moving == false:
		
		if move_step < move_max-1:
			move_step += 1
		else:
			move_step = 0	
		
		# Checks if the next movement opportunity is possible :
		var target_position = Grid.request_move(self, move_pattern[move_step])
		
		if target_position:
			# If it's possible, move to target position
			move_to(move_pattern[move_step], target_position)
		else:
			# If it ain't possible, play the idle animation
			if !move_pattern[move_step]:
				return
			animtree.set("parameters/StateMachine/Idle/blend_position", move_pattern[move_step])
			move_step -= 1

func move_to(input_direction : Vector2, target_position : Vector2):
	# Takes care of Animation Speed + Leg Switching (each step, the character swithes the leg they use)
	animtree.set("parameters/TimeScale/scale", speed)
	animtree.set("parameters/StateMachine/Walk0/blend_position", input_direction)
	animtree.set("parameters/StateMachine/Walk1/blend_position", input_direction)
	animtree.set("parameters/StateMachine/Idle/blend_position", input_direction)
	animtree["parameters/StateMachine/playback"].start("Walk" + str(int(switch_walk)))
	animtree.advance(0)
	switch_walk = !switch_walk
	
	# Moves the character at the speed of the animation (which can be modified with the speed variable)
	move_tween.interpolate_property(
		self,"position",
		position,target_position,
		walk_anim_length/speed,
		Tween.TRANS_LINEAR, Tween.EASE_IN)
	move_tween.start()
	
	is_moving = true

func _move_tween_done(_obj, _key):
	is_moving = false
