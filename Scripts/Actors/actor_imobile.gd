extends Pawn

export (Array, String) var dialogue_paths

var dialogue_txt: Array

func _ready():
	for i in dialogue_paths.size():
		dialogue_txt.append(str2var(tr(dialogue_paths[i])))

func trigger_event(_direction: Vector2):
	# Set it to null to indicate that the actor is imobile
	dialogue_manager.dialogue_setup(self, Vector2.ZERO)
