extends Dialogue

@warning_ignore("unused_signal") signal player_allow_move
@warning_ignore("unused_signal") signal npc_next_step

var return_control: bool = true

func dialogue_setup(event_dial: Array[Array], next_event_step: Callable = Callable(), is_only_event: bool = true):
	# Adds npc to signal (if assigned), then emits signal to disable movement (or something else)
	if (next_event_step): npc_next_step.connect(next_event_step)
	emit_signal("player_allow_move", false)
	emit_signal("npc_next_step", false)
	return_control = is_only_event
	
	dialogue = event_dial.duplicate() # Sets up the dialogue text
	
	# Prepares the first dialogue text and makes the dialogue box visible
	_dialogue_step(dialogue_index)
	set_active_state(true)

func handle_dialogue_steps():
	if _is_writer_done() and Input.is_action_just_pressed("ui_accept"):
		if _is_dialogue_done():
			dialogue_index = 0
			set_active_state(false) # Resets and deactivate dialogue elements
			
			emit_signal("npc_next_step", true)
			if return_control:
				emit_signal("player_allow_move", true)
				_disconnect_npc_signals()
		else:
			dialogue_index += 1 
			_dialogue_step(dialogue_index) # Next dialogue text

func set_active_state(state: bool):
	visible = state
	is_active = state

func _disconnect_npc_signals():
	for i in npc_next_step.get_connections():
		npc_next_step.disconnect(i.callable)
