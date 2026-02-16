extends Area2D

const STEP = 16
var can_swim : bool = true

signal moving
var valid_move = false
var next_pos : Vector2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var move_x = Input.get_axis("left","right")
	var move_y = Input.get_axis("up","down")
	var move = Input.is_action_just_pressed("move")
	
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
