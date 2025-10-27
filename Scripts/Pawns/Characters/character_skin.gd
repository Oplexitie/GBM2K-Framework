extends Sprite2D

var switch_walk: bool = false

@onready var animation_tree: AnimationTree =  $AnimationTree
@onready var walk_length: float = $AnimationPlayer.get_animation("walk_down").length

func set_animation_speed(value: float) -> void:
	animation_tree.set("parameters/TimeScale/scale", value)

func toggle_walk_side() -> void:
	switch_walk = !switch_walk

func play_walk_animation() -> void:
	animation_tree["parameters/StateMachine/playback"].start("Walk1" if switch_walk else "Walk0")
	animation_tree.advance(0)

func set_animation_direction(input_direction: Vector2) -> void:
	animation_tree.set("parameters/StateMachine/Idle/blend_position", input_direction)
	animation_tree.set("parameters/StateMachine/Walk1/blend_position", input_direction)
	animation_tree.set("parameters/StateMachine/Walk0/blend_position", input_direction)
