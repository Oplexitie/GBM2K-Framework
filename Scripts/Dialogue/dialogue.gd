extends Node2D
class_name Dialogue

var dialogue: Array[Array]
var dialogue_index: int = 0
var is_active: bool = false

@onready var writer: RichTextLabel = $writer

func _is_writer_done() -> bool:
	return writer.visible_characters >= len(writer.text)

func _is_dialogue_done() -> bool:
	return dialogue_index + 1 >= dialogue.size()

func _process(_delta):
	if is_active:
		handle_dialogue_steps()

func handle_dialogue_steps():
	pass

func _dialogue_step(index: int):
	# Prepares the next dialogue text
	writer.reset(dialogue[index][1][0])
	writer.bbcode_text = dialogue[index][0]
	writer.set_speed = dialogue[index][1]
	writer.set_pause = dialogue[index][2]
