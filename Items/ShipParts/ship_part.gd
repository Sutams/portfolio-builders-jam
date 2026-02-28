extends Area2D

@export var ship_part : int
@export var lang : int
@onready var sprite : Sprite2D = $Sprite2D
signal collect

var ship_part_path : Array = [  
	"res://Items/ShipParts/tot-compass.png",
	"res://Items/ShipParts/tot-sandglass.png",
	"res://Items/ShipParts/tot-sextant.png"]
	
var ship_part_name : Array = [  
	[("Compass"),("Sand Glass"),("Sextant")], # EN
	[("Brújula"),("Reloj de Arena"),("Sextante")], # ES
]
var dialogue : Array = ["You grabbed ", "Tomaste "]

func create(i : int):
	ship_part = i

func _ready() -> void:
	sprite.texture = load(ship_part_path[ship_part])

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		print(dialogue[lang], ship_part_name[lang][ship_part])
		collect.emit(global_position, ship_part_name[lang][ship_part])
		queue_free()
