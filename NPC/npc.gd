extends Node2D

@export var npc_index : int
@export var lang : int
@onready var anim : AnimatedSprite2D = $AnimatedSprite2D
signal rescue
var dialogue = [
	["Those flags save you a lot of time in case you get lost at sea"],
	["Bet those Flippers would help me swim longer"],
	["I lost the *Compass*! Maybe it washed up somewhere nearby"],
	["So many shipwrecks in one place! Think of the loot!"],
	["The Ship's right there! It survived the storm.. thank heavens"],
	["So many chests nearby!... are there any ingredients in them?"],
	["I found the *Sand Glass*!... Doesn't look like theres a way in..."],
	["Zzz... Brittle rocks... Zzz..."],
	["A pickaxe would be handy for these rocks..."],
	["So many barrels! Do you think they come from our ship?"],
	["I see the *Sextant*! Can you help me get it?"],
	["Do you think there was anyone on this place before we shipwrecked?"],
	["I could tell you a thing or two about this place..."],
	["Could you help me get back to the ship?"],
	["That fool took my pickaxe and fell asleep!"],
	["I've been in this place for years... Could teach you a thing or two"],
	["I saw a mysterious man down there"],
]

func create(i : int, lan : int):
	npc_index = i
	lang = lan
	
func _ready() -> void:
	anim.play(str(npc_index))

func _on_rescue_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		rescue.emit(global_position)
		queue_free()

func _on_talk_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		DialogueManager.start_dialogue(global_position, dialogue[npc_index])
