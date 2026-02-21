extends Area2D

@onready var animation = $AnimatedSprite2D

var active : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation.play("inactive")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		active = true
		animation.play("active")
	pass # Replace with function body.
