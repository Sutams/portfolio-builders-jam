extends Area2D

@onready var animation : AnimatedSprite2D = $AnimatedSprite2D
signal add

func _ready() -> void:
	animation.play("Idle")

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		add.emit(global_position)
		queue_free()
