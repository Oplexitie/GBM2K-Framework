extends Character

func trigger_event(direction: Vector2i) -> void:
	if not is_moving:
		chara_skin.set_animation_direction(-direction) # Face player
		print("NPC")
