extends Node

@onready var text_box_scene = preload("res://UI/TextBox/TextBox.tscn")

var dialogue_lines: Array = []
var current_line_index = 0

var text_box
var text_box_position : Vector2

var is_dialogue_active = false
var can_advance_line = false

func _on_text_box_finished_displaying():
	can_advance_line = true

func show_text_box():
	text_box = text_box_scene.instantiate()
	text_box.finished_displaying.connect(_on_text_box_finished_displaying)
	get_tree().root.add_child(text_box)
	text_box.global_position = text_box_position
	text_box.display_text(dialogue_lines[current_line_index])
	can_advance_line = false
	
func start_dialogue(pos : Vector2, lines: Array):
	if is_dialogue_active:
		return
	
	dialogue_lines = lines
	text_box_position = pos
	show_text_box()
	
	is_dialogue_active = true

func _unhandled_input(event: InputEvent) -> void:
	if (event #Input.is_anything_pressed()
		and is_dialogue_active 
		and can_advance_line
	):
		text_box.queue_free()
		current_line_index += 1
		if current_line_index >= dialogue_lines.size():
			is_dialogue_active = false
			current_line_index = 0
			return
		
		show_text_box()
