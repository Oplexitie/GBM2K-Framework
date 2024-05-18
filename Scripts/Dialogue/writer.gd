extends RichTextLabel

var txt_speed = 0.02
var skip_buffer = 0
var set_pause = {}
var set_speed = {}

@onready var timer = $timer

func _timer_timeout() -> void:
	if visible_characters < len(text) - 1:
		if visible_characters in set_pause.keys() and !set_pause.is_empty():
			timer.start(set_pause[visible_characters])
		else:
			timer.start(txt_speed)
	
	if visible_characters in set_speed.keys() and !set_speed.is_empty():
		txt_speed = set_speed[visible_characters]
	
	visible_characters += 1
	
	# When the text is completely typed out, stop the timer
	if visible_characters == len(text):
		stop()

func _process(delta: float) -> void:
	# If the cancel button is pressed then all the text typing is skipped
	if Input.is_action_just_pressed("ui_cancel") and skip_buffer < 0:
		stop()
	
	if skip_buffer > -1:
		skip_buffer -= 30 * delta

func stop() -> void:
	timer.stop()
	visible_characters = len(text)

func reset(speed : float = 0.02):
	txt_speed = speed
	skip_buffer = 2
	
	set_pause = {}
	set_speed = {}
	
	visible_characters = 1
	timer.start(txt_speed)
