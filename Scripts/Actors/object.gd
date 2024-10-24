extends Pawn

@warning_ignore("unused_signal") signal trigger_dialogue

@export var dialogue_keys: Array[String] 

@onready var dialogue: Array[Array] = GbmUtils.get_dialogue(dialogue_keys)

func trigger_event(_direction: Vector2i):
	# Set it to null to indicate that the actor is immobile
	emit_signal("trigger_dialogue", dialogue)
