extends Area2D

@export var active : bool
@onready var animation : AnimatedSprite2D = $AnimatedSprite2D
var can_tp : bool
signal last_visited(pos)

func _ready() -> void:
	animation.play("inactive")

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		can_tp = true
		active = true
		animation.play("active")
		last_visited.emit(position)
