extends Area2D

const TILE_SIZE : int = 16
var in_water : bool

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		if not in_water:
			position += (area.direction) * TILE_SIZE
