extends Control

@onready var pause_menu = $PauseMenu

func _on_resume_button_pressed() -> void:
	hide()
	get_tree().paused = false

func _on_options_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	pass # Replace with function body.
	

func _ready() -> void:
	hide()

func _process(_delta: float) -> void:
	if (Input.is_action_just_pressed("ui_menu") 
		or Input.is_action_just_pressed("ui_cancel")
	):
		if get_tree().paused:
			hide()
			get_tree().paused = false
		else:
			show()
			get_tree().paused = true
