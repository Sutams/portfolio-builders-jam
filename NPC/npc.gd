extends Node2D

@export var npc_index : int
@export var lang : int
@onready var anim : AnimatedSprite2D = $AnimatedSprite2D
signal rescue
var rescue_dialogue : String = "See you at the ship!"
var dialogue : Array = [
	("Heard those flags save your position until you get to another one "), 
	("Bet those *Flippers* would help with swimming around"),
	("Maybe that big ship has a *Compass*"),
	("Never seen so many shipwrecks in one place.."),
	("The *Ship*'s right there! It survived the storm.. thank heavens"),
	("Theres a lot of shipwreck nearby... could you see if theres any food in there?"),
	("I found the *Sand Glass*! Can you help me get it?"),
	("Zzz... Zzzz.... Zzz..."),
	("I hope the ship is alright.."),
	("So many barrels! Do you think they come from our ship?"),
	("I see the *Sextant*! Can you help me get it?"),
	("Do you think there was anyone on this place before we shipwrecked?"),
	("I could tell you a thing or two about this place..."),
	("Could you help me get back to the ship?"),
	("Those clouds keep going in circles..."),
	("I've been in this place for years... Could teach you a thing or two"),
	("There's a mysterious man down there"),
]

func create(i : int, lan : int):
	npc_index = i
	lang = lan
	
func _ready() -> void:
	anim.play(str(npc_index))

func _on_rescue_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		print(rescue_dialogue)
		rescue.emit()
		queue_free()


func _on_talk_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		print(dialogue[npc_index])
