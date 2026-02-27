extends Area2D

@export var ship_part : int
@export var lang : int
signal collect
var ship_part_name : Array = [  
	[("Compass"),("Sand Glass"),("Sextant")], # EN
	[("Brújula"),("Reloj de Arena"),("Sextante")], # ES
]
var dialogue : Array = ["You grabbed ", "Tomaste "]

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		print(dialogue[lang], ship_part_name[lang][ship_part])
		collect.emit()
		queue_free()
