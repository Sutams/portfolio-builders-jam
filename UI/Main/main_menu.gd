extends Node2D

@onready var cam = $MenuCamera
@onready var play_btn = $Control/PlayButton
@onready var cont_btn = $Control/ContinueButton
@onready var new_btn = $Control/NewGameButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cam.zoom = Vector2(0.624,0.624)
	cam.position = Vector2(232, 56)
	if Global.played:
		play_btn.hide()
		cont_btn.show()
		new_btn.show()
	else:
		play_btn.show()
		cont_btn.hide()
		new_btn.hide()

func _on_play_button_pressed() -> void:
	Global.game_controller.change_2d_scene("res://Level/level.tscn")
	Global.game_controller.remove_gui_scene()
	Global.played = true

func _on_continue_button_pressed() -> void:
	Global.game_controller.change_2d_scene("res://Level/level.tscn")
	Global.game_controller.remove_gui_scene()

func _on_new_game_button_pressed() -> void:
	LevelManager.new_game()
	Global.game_controller.change_2d_scene("res://Level/level.tscn")
	Global.game_controller.remove_gui_scene()
