extends Area2D

const TILE_SIZE = 16
var in_water : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		if not in_water:
			position += (area.direction) * TILE_SIZE
