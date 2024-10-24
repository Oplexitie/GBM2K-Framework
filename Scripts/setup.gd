extends Node2D

@export var dialogue_manager: Node2D

func _ready() -> void:
	_init_dialogue_signal()
	_init_pawn_signals()

func _init_dialogue_signal():
	# Setup signal to activate/deactivate player movement
	dialogue_manager.player_allow_move.connect($Pawns/Player.set_talking)

func _init_pawn_signals():
	# Setup signals to trigger dialogue
	for i in $Pawns.get_children():
		if ("dialogue_keys" in i):
			i.trigger_dialogue.connect(dialogue_manager.dialogue_setup)
