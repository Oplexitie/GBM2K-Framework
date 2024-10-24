extends Node2D

signal allow_move

var dialogue: Array[Array]
var dialogue_index: int = 0
var is_active: bool = false

@onready var player_signal: Callable = _get_player_callable()
@onready var writer: RichTextLabel = $writer

func _is_writer_done() -> bool:
	return writer.visible_characters >= len(writer.text)

func _is_dialogue_done() -> bool:
	return dialogue_index + 1 >= dialogue.size() # If all the dialogue texts have been shown, then end the dialogue

func dialogue_setup(npc_dial: Array[Array], signal_func: Callable = Callable()):
	# Adds npc to signal (if assigned), then emits signal to disable movement (or something else)
	if (signal_func): allow_move.connect(signal_func)
	emit_signal("allow_move", false)
	
	# Sets up the dialogue text
	dialogue = npc_dial.duplicate()
	
	# Prepares the first dialogue text and makes the dialogue box visible
	dialogue_index = 0
	_dialogue_step(dialogue_index)
	visible = true
	is_active = true

func _process(_delta):
	if is_active:
		handle_dialogue_steps()

func handle_dialogue_steps():
	# If the dialogue text is all typed out, and 'ui_accept' key is pressed, then load the next
	if _is_writer_done() and Input.is_action_just_pressed("ui_accept"):
		if _is_dialogue_done():
			emit_signal("allow_move", true) # Reactivates player and npc movement
			
			_disconnect_npc_signals()
			
			# Resets and deactivate dialogue elements
			visible = false
			is_active = false
			dialogue.clear()
		else:
			# Next dialogue text
			dialogue_index += 1
			_dialogue_step(dialogue_index)

func _dialogue_step(index: int):
	# Prepares the next dialogue text
	writer.reset(dialogue[index][1][0])
	writer.bbcode_text = dialogue[index][0]
	writer.set_speed = dialogue[index][1]
	writer.set_pause = dialogue[index][2]

func _disconnect_npc_signals():
	for i in allow_move.get_connections():
		if i.callable != player_signal:
			allow_move.disconnect(i.callable)

func _get_player_callable() -> Callable:
	var callable: Callable
	for i in allow_move.get_connections():
		callable = i.callable
	return callable
