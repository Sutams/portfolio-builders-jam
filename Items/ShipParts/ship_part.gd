extends Area2D

@export var lang : int
@onready var sprite : Sprite2D = $Sprite2D
signal collect
var item_name
var dict = {
	"Compass" : 0,
	"SandGlass" : 1,
	"Sextant" : 2
}

var path : Array = [  
	"res://Items/ShipParts/tot-compass.png",
	"res://Items/ShipParts/tot-sandglass.png",
	"res://Items/ShipParts/tot-sextant.png"]

func create(part_name : String):
	item_name = part_name

func _ready() -> void:
	sprite.texture = load(path[dict[item_name]])

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		collect.emit(global_position, item_name)
		queue_free()
