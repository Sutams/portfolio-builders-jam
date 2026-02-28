extends Area2D

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		area.can_mine = true
		PickUpManager.show_text(area.position, "+Flippers")
		LevelManager.pickaxe_collected = 1
		queue_free()
