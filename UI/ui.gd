extends Control

@onready var pause_menu = $PauseMenu
@onready var npc_label = $PauseMenu/NPCs/NPCLabel
@onready var flippers_label  = $PauseMenu/Flippers/FlipperLabel
@onready var key_label  = $PauseMenu/Keys/KeyLabel
@onready var loot_label  = $PauseMenu/Loot/LootLabel
@onready var pickaxe_label = $PauseMenu/Pickaxe/PickaxeLabel
@onready var ship_parts = $PauseMenu/ShipParts


var n_ship_parts : int = LevelManager.ship_part_coords.size()
var n_npcs : int = LevelManager.npc_coords.size()
var n_flippers : int = LevelManager.flipper_coords.size()
var n_keys : int = LevelManager.key_coords.size()
var n_loot : int # calculate?
var n_pickaxe : int = 1

func _on_resume_button_pressed() -> void:
	hide()
	get_tree().paused = false

func _on_options_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	pass # Replace with function body.
	

func update_collectibles():
	for part in ship_parts.get_children():
		if part.name in LevelManager.ship_parts_retrieved:
			part.set_deferred("modulate", Color(1,1,1,1))
	
	npc_label.text = str(LevelManager.npc_rescued)+"/"+str(n_npcs)
	flippers_label.text = str(LevelManager.flippers_collected)+"/"+str(n_flippers)
	key_label.text = str(LevelManager.keys_collected)+"/"+str(n_keys)
	loot_label.text = str(LevelManager.loot_collected)+"/?"
	pickaxe_label.text = str(LevelManager.pickaxe_collected)+"/"+str(1)

func _ready() -> void:
	var parts = ship_parts.get_children()
	for part in parts:
		if part.name != "TextureRect":
			part.set_deferred("modulate", Color(0,0,0,1))
	hide()

func _process(_delta: float) -> void:
	if (Input.is_action_just_pressed("ui_menu") 
		or Input.is_action_just_pressed("ui_cancel")
	):
		if get_tree().paused:
			hide()
			get_tree().paused = false
		else:
			update_collectibles()
			show()
			get_tree().paused = true
