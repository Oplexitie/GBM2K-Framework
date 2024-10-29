extends PawnMobile

const MOVEMENTS: Dictionary = {
	'ui_up': Vector2i.UP,
	'ui_left': Vector2i.LEFT,
	'ui_right': Vector2i.RIGHT,
	'ui_down': Vector2i.DOWN 
	}

# Movement Related (+ animation)
var input_history: Array[String] = []
var cur_direction: Vector2i = Vector2i.DOWN

func _process(_delta):
	input_priority()
	
	if can_move():
		if Input.is_action_just_pressed("ui_accept"): # To Request dialogue
			Grid.request_event(self, cur_direction, 0)
		
		var input_direction: Vector2i = set_direction()
		if input_direction:
			cur_direction = input_direction
			set_anim_direction(input_direction)
			
			# Checks if the next movement opportunity is possible, if it is move to target position
			var target_position: Vector2i = Grid.request_move(self, input_direction)
			if target_position:
				move_to(target_position)

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

func _move_tween_done():
	move_tween.kill()
	switch_walk = !switch_walk
	Grid.request_event(self, Vector2i.ZERO, 2) # Check if there's an event
	is_moving = false

func set_talking(talk_state: bool):
	is_talking = !talk_state
	if is_talking: input_history.clear()
