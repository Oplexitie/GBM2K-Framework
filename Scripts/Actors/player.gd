extends Pawn

const MOVEMENTS: Dictionary = {
	'ui_up': Vector2i.UP,
	'ui_left': Vector2i.LEFT,
	'ui_right': Vector2i.RIGHT,
	'ui_down': Vector2i.DOWN 
	}

@export var speed: float = 1.5

# Movement Related (+ animation)
var input_history: Array[String] = []
var is_moving: bool = false
var is_talking: bool = false
var switch_walk: bool = false
var move_tween: Tween
# Dialogue Related (talk direction)
var cur_direction: Vector2i = Vector2i.DOWN

@onready var Grid: TileMapLayer = get_parent()
@onready var animtree: AnimationTree =  $AnimationTree
@onready var walk_anim_length: float = $AnimationPlayer.get_animation("walk_down").length

func _process(_delta):
	input_priority()
	
	# Allow movement if conditions are meet
	if !is_moving and !is_talking:
		# To Request dialogue
		if Input.is_action_just_pressed("ui_accept"):
			Grid.request_diag(self, cur_direction)
		
		var input_direction: Vector2i = set_direction()
		
		if input_direction:
			# Checks if the next movement opportunity is possible
			cur_direction = input_direction
			var target_position: Vector2i = Grid.request_move(self, input_direction)
			
			if target_position:
				# If it's possible, move to target position
				move_to(input_direction,target_position)
			else:
				# If it ain't possible, then set idle direction
				animtree.set("parameters/StateMachine/Idle/blend_position", input_direction)

func input_priority():
	# Input prioritie system, prioritize the latest inputs
	for direction in MOVEMENTS.keys():
		if Input.is_action_just_released(direction):
			var index: int = input_history.find(direction)
			if index != -1:
				input_history.remove_at(index)
		
		if Input.is_action_just_pressed(direction):
			input_history.append(direction)

func set_direction() -> Vector2i:
	# Handles the movement direction depending on the inputs
	var direction: Vector2i = Vector2i()
	
	if input_history.size():
		for i in input_history:
			direction += MOVEMENTS[i]
		
		match(input_history.back()):
			'ui_right', 'ui_left': if direction.x != 0: direction.y = 0
			'ui_up', 'ui_down': if direction.y != 0: direction.x = 0
	
	return direction

func move_to(input_direction: Vector2i, target_position: Vector2):
	# Takes care of Animation Speed + Leg Switching (each step, the character swithes the leg they use)
	var str_switch: String = str(int(switch_walk))
	animtree.set("parameters/TimeScale/scale", speed)
	animtree.set("parameters/StateMachine/Idle/blend_position", input_direction)
	animtree.set("parameters/StateMachine/Walk" + str_switch +"/blend_position", input_direction)
	animtree["parameters/StateMachine/playback"].start("Walk" + str_switch)
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
