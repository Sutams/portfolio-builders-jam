extends Area2D

@onready var animation = $AnimatedSprite2D

@export var active : bool
var can_tp : bool

signal last_visited(pos)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation.play("inactive")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		can_tp = true
		active = true
		animation.play("active")
		
		last_visited.emit(position)
	pass # Replace with function body.
