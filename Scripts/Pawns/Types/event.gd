extends Pawn

@warning_ignore("unused_signal") signal trigger_dialogue

@export var dialogue_keys: Array[String]
@export var dialogue_2_keys: Array[String] 

var event_step:int = 0

@onready var dialogue: Array[Array] = GbmUtils.get_dialogue(dialogue_keys)
@onready var dialogue_2: Array[Array] = GbmUtils.get_dialogue(dialogue_2_keys)

func trigger_event(can_proceed: bool = true):
	if can_proceed:
		match event_step:
			0:
				# Sends dialogue, prepares the next function, and prevents controls from being restored
				emit_signal("trigger_dialogue", dialogue, trigger_event, false)
				event_step += 1
			1:
				await get_tree().create_timer(1.0).timeout
				# Only sends dialogue, so the controls will be restored and that's it
				emit_signal("trigger_dialogue", dialogue_2)
				event_step += 1
			_:
				event_step = 0
