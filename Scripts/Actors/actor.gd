extends "pawn.gd"

@export var speed : float = 1.5
@export var move_pattern : Array[Vector2]
@export var dialogue_paths : Array[String] 

# Movement Related (+ animation)
var move_step : int = 0
var is_moving : bool = false
var is_stopped : bool = false
var is_talking : bool = false
var switch_walk : bool = false
var move_tween : Tween
var dialogue_txt : Array

@onready var move_max : int = move_pattern.size()
@onready var Grid : TileMap = get_parent()
@onready var animtree : AnimationTree =  $AnimationTree
@onready var walk_anim_length : float = $AnimationPlayer.get_animation("walk_down").length

func _ready():
	for i in dialogue_paths.size():
		dialogue_txt.append(str_to_var(tr(dialogue_paths[i])))

func _process(_delta):
	if !is_talking and !is_stopped and !is_moving:
		# Loops movement when move_step is equal to 0
		move_step += 1
		if move_step >= move_max: move_step = 0
		
		# Checks if the next movement opportunity is possible :
		var current_step : Vector2 = move_pattern[move_step]	
		var target_position = Grid.request_move(self, current_step)
		
		if target_position:
			# If it's possible, move to target position
			move_to(current_step, target_position)
		else:
			# If it ain't possible, and current_step is something then set idle direction
			if current_step:
				animtree.set("parameters/StateMachine/Idle/blend_position", current_step)
				move_step -= 1
			else:
				wait()

func move_to(input_direction : Vector2, target_position : Vector2):
	# Takes care of Animation Speed + Leg Switching (each step, the character swithes the leg they use)
	var str_switch : String = str(int(switch_walk))
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

func wait():
	is_stopped = true
	await get_tree().create_timer(1.0).timeout
	is_stopped = false

func _move_tween_done():
	move_tween.kill()
	switch_walk = !switch_walk
	is_moving = false

func trigger_event(direction : Vector2):
	dialogue_manager.dialogue_setup(self, direction)
