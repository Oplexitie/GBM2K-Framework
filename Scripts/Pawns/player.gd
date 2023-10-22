extends "pawn.gd"

const MOVEMENTS : Dictionary = {
	'ui_up': Vector2.UP,
	'ui_left': Vector2.LEFT,
	'ui_right': Vector2.RIGHT,
	'ui_down': Vector2.DOWN 
	}

export var speed : float = 1.5

var input_history : Array = []
var is_moving : bool = false
var switch_walk : bool = false

onready var Grid : TileMap = get_parent()
onready var animtree : AnimationTree =  $AnimationTree
onready var move_tween = $Tween
onready var walk_anim_length : float = $AnimationPlayer.get_animation("walk_down").length

func _process(_delta):
	input_dir_priority()
	
	if is_moving == false:
		var input_direction : Vector2 = direction_buffer()
		if !input_direction:
			return
		
		# Checks if the next movement opportunity is possible :
		var target_position = Grid.request_move(self, input_direction)
		
		# If it's possible, move to target position
		# If it ain't possible, play the idle animation
		if target_position:
			move_to(input_direction, target_position)
		else:
			animtree.set("parameters/StateMachine/Idle/blend_position", input_direction)

func input_dir_priority():
	# Input prioritie system, prioritize the latest inputs
	for direction in MOVEMENTS.keys():
		if Input.is_action_just_released(direction):
			var index : int = input_history.find(direction)
			if index != -1:
				input_history.remove(index)
		if Input.is_action_just_pressed(direction):
			input_history.append(direction)

func direction_buffer():
	# If only one key is pressed, apply the latest input from the array to input_direction
	# If two kesy are being pressed, check if the input are in opposite directions, if yes, then prevent movement
	var history_size : int = input_history.size()
	
	if (history_size == 1):
		return MOVEMENTS[input_history[history_size - 1]]
	elif (history_size == 2):
		match(input_history[history_size - 1]):
			'ui_right', 'ui_left':
				return Vector2(MOVEMENTS[input_history[history_size - 1]].x + MOVEMENTS[input_history[history_size - 2]].x, 0)
			'ui_up', 'ui_down':
				return Vector2(0, MOVEMENTS[input_history[history_size - 1]].y + MOVEMENTS[input_history[history_size - 2]].y)			
	return Vector2()

func move_to(input_direction : Vector2, target_position : Vector2):
	# Takes care of Animation Speed + Leg Switching (each step, the character swithes the leg they use)
	animtree.set("parameters/TimeScale/scale", speed)
	animtree.set("parameters/StateMachine/Walk" + str(int(switch_walk)) +"/blend_position", input_direction)
	animtree.set("parameters/StateMachine/Idle/blend_position", input_direction)
	animtree["parameters/StateMachine/playback"].start("Walk" + str(int(switch_walk)))
	animtree.advance(0)
	
	# Moves the character at the speed of the animation (which can be modified with the speed variable)
	move_tween.interpolate_property(
		self,"position", position,target_position,
		walk_anim_length/speed, Tween.TRANS_LINEAR, Tween.EASE_IN)
	move_tween.start()

	is_moving = true

func _move_tween_done(_obj, _key):
	switch_walk = !switch_walk
	is_moving = false
