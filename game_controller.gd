class_name GameController extends Node

@export var world_2d : Node2D
@export var gui : Control

var current_2d_scene : Node
var current_gui_scene : Node

func _ready() -> void:
	Global.game_controller = self
	change_gui_scene("res://UI/Main/main_menu.tscn")

##
func change_2d_scene(scene_path: String, delete: bool = true, keep_running: bool = false):
	if current_2d_scene != null:
		if delete:
			current_2d_scene.queue_free() # Remove node entirely
		elif keep_running:
			current_2d_scene.visible = false # Keep in memory and running
		else:
			world_2d.remove_child(current_2d_scene) # Keep in memory
	var new_scene = load(scene_path).instantiate()
	world_2d.add_child(new_scene)
	current_2d_scene = new_scene

func remove_2d_scene():
	world_2d.remove_child(current_2d_scene) # Keep in memory
	
##
func change_gui_scene(scene_path: String, delete: bool = true):
	if current_gui_scene != null:
		if delete:
			current_gui_scene.queue_free() # Remove node entirely
		#elif keep_running:
			#current_gui_scene.visible = false # Keep in memory and running
		#else:
			#gui.remove_child(current_gui_scene) # Keep in memory
	var new_scene = load(scene_path).instantiate()
	gui.add_child(new_scene)
	current_gui_scene = new_scene

func remove_gui_scene():
	gui.remove_child(current_gui_scene) # Keep in memory
