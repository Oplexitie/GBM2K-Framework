extends PawnMobile

@warning_ignore("unused_signal") signal trigger_dialogue

@export var move_pattern: Array[Vector2i]
@export var dialogue_keys: Array[String] 

# Movement Related (+ animation)
var move_step: int = 0

@onready var move_max: int = move_pattern.size()
@onready var dialogue: Array[Array] = GbmUtils.get_dialogue(dialogue_keys)

func _process(_delta):
	# Allow movement if conditions are meet
	if can_move():
		var current_step: Vector2i = move_pattern[move_step]	
		if current_step:
			set_anim_direction(current_step)
			
			# Checks if the next movement opportunity is possible, if it is move to target position
			var target_position: Vector2i = Grid.request_move(self, current_step)
			if target_position:
				move_to(target_position)
			else:
				return # If player is in the way, return to avoid adding to move_step
		else:
			wait()
		
		# Loops movement when move_step is equal to 0
		move_step += 1
		if move_step >= move_max: move_step = 0

func wait():
	is_stopped = true
	await get_tree().create_timer(1.0).timeout
	is_stopped = false

func trigger_event(direction: Vector2i):
	if not is_moving:
		set_anim_direction(-direction) # Face player
		emit_signal("trigger_dialogue", dialogue, set_talking)
