extends Area2D

@onready var animation : AnimatedSprite2D = $AnimatedSprite2D
var can_tp : bool
var active : bool
signal last_visited(pos)

func _ready() -> void:
	animation.play("inactive")

func activate(): 
	active = true
	animation.play("active")

func deactivate(): 
	active = false
	animation.play("inactive")
	
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		can_tp = true
		activate()
		last_visited.emit(position)
