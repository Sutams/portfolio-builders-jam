extends Area2D

const TILE_SIZE : int = 16

@export var keys : int = 0
@export var can_dive : bool = false
@export var can_tp : bool = true
var next_pos : Vector2
var valid_move : bool = false
signal moving

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var move_x = Input.get_axis("left","right")
	var move_y = Input.get_axis("up","down")
	var move = Input.is_action_just_pressed("move")
	# Need to check if movement is allowed!
	# Get the position you'll be in from the map and see if its water 
	if move:
		next_pos.x = position.x + move_x * TILE_SIZE
		next_pos.y = position.y + move_y * TILE_SIZE
		moving.emit()
	if valid_move:
		if move_x:
			position.x += move_x * TILE_SIZE
		if move_y:
			position.y += move_y * TILE_SIZE
	valid_move = false
	pass

func add_key():
	keys += 1

func key_used():
	keys -= 1
