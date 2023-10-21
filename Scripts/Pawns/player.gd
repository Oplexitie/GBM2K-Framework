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
	# Input prioritie system, prioritize the latest inputs
	var input_direction = Vector2()
	for direction in MOVEMENTS.keys():
		if Input.is_action_just_released(direction):
			var index = input_history.find(direction)
			if index != -1:
				input_history.remove(index)
		if Input.is_action_just_pressed(direction):
			input_history.append(direction)
	
	if is_moving == false:
		# If only one key is pressed, apply the latest input from the array to input_direction
		# If two kesy are being pressed, check if the input are in opposite directions, if yes, then prevent movement
		var history_size = input_history.size()
		
		if (history_size == 1):
			input_direction = MOVEMENTS[input_history[history_size - 1]]
		elif (history_size == 2):
			match(input_history[history_size - 1]):
				'ui_right', 'ui_left':
					input_direction.x = MOVEMENTS[input_history[history_size - 1]].x + MOVEMENTS[input_history[history_size - 2]].x
				'ui_up', 'ui_down':
					input_direction.y = MOVEMENTS[input_history[history_size - 1]].y + MOVEMENTS[input_history[history_size - 2]].y
		
		# Checks if the next movement opportunity is possible :
		var target_position = Grid.request_move(self, input_direction)
		
		if target_position:
			# If it's possible, move to target position
			move_to(input_direction, target_position)
		else:
			# If it ain't possible, play the idle animation
			if !input_direction:
				return
			animtree.set("parameters/StateMachine/Idle/blend_position", input_direction)

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
