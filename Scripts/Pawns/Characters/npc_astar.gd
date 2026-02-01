extends Character

@export var targets: Array[Vector2i]

var is_stopped: bool = false
var path: Array[Vector2i]
var move_max: int
var move_step: int = 0
var curr_target: int = 0

func _process(_delta) -> void:
	if is_stopped:
		return
	
	if can_move():
		get_astar_path()
		
		var current_step: Vector2i = path.get(move_step)
		chara_skin.set_animation_direction(current_step)
		
		# Checks if the next movement opportunity is possible, if it is move to target position
		var target_position: Vector2i = Grid.request_move(self, current_step)
		if not target_position:
			path.clear()
			return
		move_to(target_position)
		
		# Loops movement when move_step is equal to 0
		move_step += 1
		if move_step >= move_max:
			wait()
			path.clear()
			curr_target = wrap(curr_target + 1, 0, 3)

func get_astar_path() -> void:
	if path.is_empty():
		path = Grid.get_astar_path(self, targets[curr_target])
		move_max = path.size()
		move_step = 0

func wait() -> void:
	is_stopped = true
	await get_tree().create_timer(1.0).timeout
	is_stopped = false

func trigger_event(direction: Vector2i) -> void:
	if not is_moving:
		chara_skin.set_animation_direction(-direction) # Face player
		print("NPC AStar")
