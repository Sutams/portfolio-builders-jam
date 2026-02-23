extends Area2D

const STEP = 16

@export var keys = 0
var can_swim = true
var respawning = false
var direction : Vector2
var next_pos : Vector2
var valid_move = false
signal moving

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var move_x = Input.get_axis("left","right")
	var move_y = Input.get_axis("up","down")
	var move = Input.is_action_just_pressed("move")
	direction = Vector2(move_x, move_y)
	
	if respawning:
		direction = Vector2.ZERO
		return
	
	# Need to check if movement is allowed!
	# Get the position you'll be in from the map and see if its water 
	if move:
		next_pos.x = position.x + move_x * STEP
		next_pos.y = position.y + move_y * STEP
		moving.emit()
	if valid_move:
		if move_x:
			position.x += move_x * STEP
		if move_y:
			position.y += move_y * STEP
	valid_move = false
	pass

func add_key():
	keys += 1

func key_used():
	keys -= 1
