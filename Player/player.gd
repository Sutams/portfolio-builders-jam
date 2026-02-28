extends Area2D

const TILE_SIZE : int = 16

@onready var animate = $AnimatedSprite2D
var next_pos : Vector2
var valid_move : bool = false
var idle_time : float = 0.0
signal moving

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var move_x = Input.get_axis("left","right")
	var move_y = Input.get_axis("up","down")
	var move = Input.is_action_just_pressed("move")
	# Need to check if movement is allowed!
	# Get the position you'll be in from the map and see if its water 
	if DialogueManager.is_dialogue_active:
		return
	if move:
		next_pos.x = position.x + move_x * TILE_SIZE
		next_pos.y = position.y + move_y * TILE_SIZE
		moving.emit()
	if valid_move:
		if move_x:
			position.x += move_x * TILE_SIZE
		if move_y:
			position.y += move_y * TILE_SIZE
	
	# Manage animations
	if move:
		idle_time = 0
		if move_x > 0:
			animate.play("WalkRight")
		elif move_x < 0:
			animate.play("WalkLeft")
		if move_y > 0:
			animate.play("WalkFront")
		elif move_y < 0:
			animate.play("WalkBack")
	else:
		idle_time +=  delta
		if idle_time > 0.5:
			animate.play("Idle")
			idle_time = 0
	valid_move = false
