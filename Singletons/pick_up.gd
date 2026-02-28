extends Control

const MAX_WIDTH = 128

var new_font = preload("res://UI/Font/m3x6.ttf")

var margcont : MarginContainer
var label : Label
var timer : Timer

var fade_in : bool = false

func _ready() -> void:
	label = Label.new()
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", new_font)
	label.add_theme_color_override("font_color", Color("a85f00"))
	label.add_theme_color_override("font_outline_color", Color(0,0,0,1))
	label.add_theme_constant_override("outline_size", 2)
	label.add_theme_font_size_override("font_size", 16)
	add_child(label)
	timer = Timer.new()
	add_child(timer)

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
	global_position.y -= 20
	label.text = txt
	await get_tree().create_timer(1).timeout
	fade_in = false
	label.text = ""
