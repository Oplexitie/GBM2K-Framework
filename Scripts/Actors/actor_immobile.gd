extends Pawn

@export var dialogue_paths: Array[String] 

var dialogue_txt: Array[Array]

func _ready():
	for i in dialogue_paths.size():
		dialogue_txt.append(str_to_var(tr(dialogue_paths[i])))

func trigger_event(_direction: Vector2i):
	# Set it to null to indicate that the actor is imobile
	dialogue_manager.dialogue_setup(self, Vector2i.ZERO)
