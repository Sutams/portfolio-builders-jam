extends Area2D

signal activate

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		activate.emit()
		queue_free()
