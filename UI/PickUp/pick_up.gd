extends Control

const MAX_WIDTH = 128

@onready var label : Label = $MarginContainer/Label
@onready var timer = $Timer

var fade_in : bool = false


func _process(delta: float) -> void:
	global_position.y -= delta*5
	if fade_in:
		label.self_modulate = Color(1,1,1,1)
	else:
		label.self_modulate = Color(0,0,0,0)


func show_text(pos : Vector2, txt : String):
	fade_in = true
	global_position = pos
	#global_position.x -= 10
	global_position.y -= 30
	label.text = txt
	await get_tree().create_timer(1).timeout
	fade_in = false
	label.text = ""
