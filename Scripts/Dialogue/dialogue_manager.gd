extends Node2D

@export var char_player_path : NodePath

var dialogue_index : int = 0
var char_npc : Node2D
var npc_dir : Vector2

@onready var char_player : Node2D = get_node(char_player_path)
@onready var writer : RichTextLabel = $writer

func _process(_delta):
	if char_player.is_talking:
		# If the dialogue is done and the accept key is pressed, the next block of text gets loaded in
		# If the next block of text is empty then end the dialogue
		if Input.is_action_just_pressed("ui_accept") and writer.visible_characters == len(writer.text):
			if char_npc.dialogue_txt[dialogue_index + 1].is_empty():
				dialogue_index = 0
				visible = false
				writer.reset()
				
				# Reactivates player and npc movement, for the npc it's if the actor is mobile
				char_player.is_talking = false
				if npc_dir: char_npc.is_talking = false
			else:
				# Next block of text
				dialogue_index += 1
				dialogue_step()

func dialogue_setup(npc : Node2D, direction : Vector2):
	# Sets up the dialogue event
	# If direction is equal to Vector2.ZERO then it's an immobile actor (ex. chair)
	# If not equal to Vector2.ZERO then it's a mobile actor (ex. npc)
	if direction:
		if npc.is_moving: return
		# Deactivates npc movement and makes the npc face the player during dialogue
		npc.is_talking = true
		npc.animtree.set("parameters/StateMachine/Idle/blend_position", -direction)
	
	# Saves the npc node and direction for later (in _process() and dialogue_step)
	char_npc = npc
	npc_dir = direction
	
	# The player's input history is emptied to avoid any extra movements from happening
	char_player.input_history = []
	char_player.is_talking = true
	
	# Prepares the first block of text and makes the dialogue box visible
	visible = true
	dialogue_step()

func dialogue_step():
	# Prepares the next block of text
	writer.reset(char_npc.dialogue_txt[dialogue_index][1][0])
	writer.bbcode_text = char_npc.dialogue_txt[dialogue_index][0]
	writer.set_speed = char_npc.dialogue_txt[dialogue_index][1]
	writer.set_pause =  char_npc.dialogue_txt[dialogue_index][2]
