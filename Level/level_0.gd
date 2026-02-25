extends Node2D

# Scenes to instantiate
@export var checkpoint_scene : PackedScene
@export var key_scene : PackedScene
@export var flipper_scene : PackedScene
@export var swim_level : int = 0

# Nodes to work with
@onready var tilemap : TileMapLayer = $Ground
@onready var tilemap_above : TileMapLayer = $AboveWater
@onready var tide_timer : Timer = $TideTimer
@onready var fall_timer : Timer = $FallTimer
@onready var player : Area2D = $Player
@onready var camera : Camera2D = $Camera2D
@onready var area_camera : Area2D = $Camera2D/AreaCamera
@onready var checkpoint_container : Node = $Checkpoints
@onready var key_container : Node = $Keys
@onready var flipper_container : Node = $Flippers

# Constant variables
const TILE_SIZE : int = 16 # Square tiles of 16px size
const OFFSET : Vector2 = Vector2(.5,.5)

# Rest of variables
var cam_x_offset : int 
var cam_y_offset : int
var camera_origin : Vector2
var camera_vector : Vector2 = Vector2.ZERO
var spawnpoint : Vector2 = Vector2(1,1)
var time_in_water : float = 0.0
var rise : bool = true
var tide_height : int = 0
var max_tide : int
var swim_time : float = 0.1
var max_water_time : float = 0.2

# Tilemap related
var tilemap_copy : TileMapLayer
var tilemap_above_copy : TileMapLayer
const type : Dictionary = { 
	"Deep Water" : 0, # <- Y-coord on tilemap atlas
	"Water" : 1,
	"Grass" : 2,
	"Sand" : 3,
	"Wood" : 4,
	"Wall" : 5,
	"Mountain" : 6,
	"Lava" : 7, 
	"Lilypad" : 8,
	"Barrel" : 9,
	"Rock" : 10,
	"Lock" : 11,
	}
# List of tiles the player can move on
var water_tiles : Array = [type["Deep Water"], type["Water"]]
var flood_tiles : Array = [type["Grass"], type["Sand"], type["Wood"]]
var obstacle_tiles : Array = [type["Wall"], type["Rock"], type["Lock"]]
var stand_tiles : Array = [type["Lilypad"], type["Barrel"]]

# List to keep tiles that have been stood on
var falling_cells : Array = []
var rising_cells : Array = []

# Spawn coords
var key_coords : Array = [
	Vector2(21,6), Vector2(39,6), Vector2(44,24), Vector2(4,22), Vector2(21,37),
	]
var flipper_coords : Array = [
	Vector2(29,6), Vector2(16,29), 
	]
var checkpoint_coords : Array = [
	Vector2(39,-2),
	Vector2(1,1), Vector2(24,11), Vector2(63,8),
	Vector2(14,15), Vector2(43,17), Vector2(54,23),
	Vector2(4,36), Vector2(35,32)
	]
var checkpoints : Array = []
var last_visited_checkpoint : Area2D

## Converts a position into tilemap coordinates
func to_coords(pos: Vector2) -> Vector2:
	return (pos / TILE_SIZE) - OFFSET

## Saves the position of the last checkpoint passed over
## and changes other checkpoints as inactive (for respawning)
func last_checkpoint(pos : Vector2):
	for i in len(checkpoints):
		if to_coords(pos) == checkpoint_coords[i]:
			last_visited_checkpoint = checkpoints[i]
		else:
			checkpoints[i].active = false


## Removes the key from the scene and list and adds it to the player
func add_key(pos : Vector2):
	for i in len(key_coords):
		if to_coords(pos) == key_coords[i]:
			key_coords.pop_at(i)
			player.add_key()
			return

## Calculates camera vector based on how many times 
## the current position fits in the camera offsets
func camera_vector_range(pos : Vector2):
	# How many times does it have to move in the X and Y axis
	var range_x = int(pos.x / cam_x_offset)
	var range_y = int(pos.y / cam_y_offset)
	# Because there is no -0, the value must be lowered once more if its negative
	if pos.x < 0:
		range_x -= 1
	if pos.y < 0:
		range_y -= 1
	camera_vector.x = range_x
	camera_vector.y = range_y

## Adds time to the max water time 
func swim_level_up():
	swim_level += 1
	max_water_time += swim_time

## Changes the player position and moves the camera accordingly
func respawn():
	# Sets player position to the last checkpoint or the spawn point
	if last_visited_checkpoint:
		player.position = last_visited_checkpoint.position
	else:
		player.position = (spawnpoint + OFFSET) * TILE_SIZE
	# Changes the camera vector to correspondent checkpoint or spawn
	if last_visited_checkpoint: 
		camera_vector_range(to_coords(last_visited_checkpoint.position))
	else:
		camera_vector.x = 0
		camera_vector.y = 0
	move_camera()

## Manages the rise and lowering of the tides by changing the tilemap
func _on_tide_timer_timeout() -> void:
	var used_cells = tilemap.get_used_cells()
	# Cycle through whole tilemap
	for cell in used_cells:
		var tile = tilemap.get_cell_atlas_coords(cell)
		var tile_copy = tilemap_copy.get_cell_atlas_coords(cell)
		if rise:
			# Turns into water the tiles that can be flood
			if tile.x == tide_height and tile.y in flood_tiles:
				tilemap.set_cell(cell, 0 , Vector2i(max_tide, type["Water"]))
			# If it's already water, change its color to deeper water
			elif tile.x > 0 and tile.y == type["Water"]:
				tilemap.set_cell(cell, 0 , Vector2i(tile.x-1, type["Water"]))
			elif tile.x > 0 and tile.y == type["Deep Water"]:
				tilemap.set_cell(cell, 0 , Vector2i(tile.x-1, type["Deep Water"]))
		else:
			# Tiles go back to normal using the original values in the copied tilemap
			if tile_copy.x == tide_height-1 and tile_copy.y in flood_tiles:
				tilemap.set_cell(cell, 0 , tile_copy)
			# Changes the water color if the tile is gonna be back to normal next time 
			elif tile.y == type["Water"] and tile_copy.y in flood_tiles:
				tilemap.set_cell(cell, 0 , Vector2i(tile.x+1, type["Water"]))
			# Make the water tiles clearer till its back to normal
			elif tile_copy.y == type["Water"] and tile.x < tile_copy.x:
				tilemap.set_cell(cell, 0 , Vector2i(tile.x+1, type["Water"]))
			elif tile_copy.y == type["Deep Water"] and tile.x < tile_copy.x:
				tilemap.set_cell(cell, 0 , Vector2i(tile.x+1, type["Deep Water"]))
	# Rises and lowers the tide
	if rise:
		tide_height+=1
	else:
		tide_height-=1
	if tide_height == 0 or tide_height == max_tide:
		rise = !rise
		# Stops tide movement for a short random time
		tide_timer.paused = true
		if tide_height == 0:
			await get_tree().create_timer(randi_range(2,5)).timeout
		else:
			await get_tree().create_timer(randi_range(1,4)).timeout
		tide_timer.paused = false

## Allows player to move by checking the "type" of tile in the tilemap
func _on_player_moving() -> void:
	var next_tilemap_position = Vector2i(to_coords(player.next_pos))
	var tile_stood = tilemap_above.get_cell_atlas_coords(next_tilemap_position)
	# Check if next move is allowed based on tile's Y-coord on atlas tilemap
	if tilemap_above.get_cell_atlas_coords(next_tilemap_position).y in obstacle_tiles:
		player.valid_move = false
		# Opens lock
		if tilemap_above.get_cell_atlas_coords(next_tilemap_position).y == type["Lock"]:
			if player.keys > 0:
				player.valid_move = true
				player.key_used()
				tilemap_above.set_cell(next_tilemap_position, -1 , Vector2i(-1,-1))
	#elif player.next_pos == $Block.position:
		#player.valid_move = true
	else:
		player.valid_move = true
	
	# Check if next move is falling tile
	if tile_stood.y in stand_tiles:
		if tile_stood not in falling_cells:
			falling_cells.append(next_tilemap_position)

## Moves the camera depending on players direction
##
func move_camera():
	camera.position.x = camera_origin.x + camera_vector.x * TILE_SIZE * cam_x_offset
	camera.position.y = camera_origin.y + camera_vector.y * TILE_SIZE * cam_y_offset
	# Gives small to avoid area moving bug
	area_camera.set_deferred("monitoring",false)
	await get_tree().create_timer(.1).timeout
	area_camera.set_deferred("monitoring",true)

## Keeps track of where the camera should go
##
func _on_area_camera_area_exited(area: Area2D) -> void:
	if area.is_in_group("player"):
		camera_vector_range(to_coords(area.position))
		move_camera()
##
##
func _on_fall_timer_timeout() -> void:
	# Cycle through whole tilemap
	if falling_cells:
		for cell in falling_cells:
			var tile = tilemap_above.get_cell_atlas_coords(cell)
			if tile.x > 0:
				tilemap_above.set_cell(cell, 0 , Vector2i(tile.x-1, tile.y))
			elif tile.x < 0:
				tilemap_above.set_cell(cell, 0 , Vector2i(tile.x+1, tile.y))
			else:
				tilemap_above.set_cell(cell, -1 , Vector2i(-1,-1))
				falling_cells.erase(cell)
				await get_tree().create_timer(randi_range(1,3)).timeout
				rising_cells.append(cell)
	
	if rising_cells:
		for cell in rising_cells:
			var tile = tilemap_above.get_cell_atlas_coords(cell)
			var tile_copy = tilemap_above_copy.get_cell_atlas_coords(cell)

			if tile.x < tile_copy.x and tile.x < max_tide:
				tilemap_above.set_cell(cell, 0 , Vector2i(tile.x+1, tile_copy.y))
			else:
				rising_cells.erase(cell)

##
##
##
func _ready() -> void:
	# Initialize variables
	camera_origin = camera.position
	
	# Assigns the N° of tiles that fit in the screen
	cam_x_offset = ProjectSettings.get_setting("display/window/size/viewport_width") / TILE_SIZE
	cam_y_offset = ProjectSettings.get_setting("display/window/size/viewport_height") / TILE_SIZE
	camera_vector_range(to_coords(player.position))
	move_camera()
	
	# Create copy tilemap to keep track of original values
	tilemap_copy = TileMapLayer.new()
	tilemap_copy.set_tile_map_data_from_array(tilemap.get_tile_map_data_as_array())
	tilemap_above_copy = TileMapLayer.new()
	tilemap_above_copy.set_tile_map_data_from_array(tilemap_above.get_tile_map_data_as_array())
	
	# Determines n° of times the water rises
	# based on max n° of tiles in the X-axis on the atlas
	# (every row should have the same amount!)
	max_tide = 0
	var used_cells = tilemap.get_used_cells()
	for cell in used_cells:
		var tile = tilemap.get_cell_atlas_coords(cell)
		if tile.x > max_tide:
			max_tide = tile.x
	
	# Places the objects in the map
	for coord in checkpoint_coords:
		var new_node = checkpoint_scene.instantiate()
		new_node.last_visited.connect(last_checkpoint)
		new_node.global_position = (coord + OFFSET) * TILE_SIZE
		checkpoint_container.add_child(new_node)
		checkpoints.append(new_node)
		new_node.owner = get_tree().edited_scene_root
		
	for coord in key_coords:
		var new_node = key_scene.instantiate()
		new_node.add.connect(add_key)
		new_node.global_position = (coord + OFFSET) * TILE_SIZE
		key_container.add_child(new_node)
	
	for coord in flipper_coords:
		var new_node = flipper_scene.instantiate()
		new_node.activate.connect(swim_level_up)
		new_node.global_position = (coord + OFFSET) * TILE_SIZE
		flipper_container.add_child(new_node)
	
	# For debug purposes
	max_water_time = max_water_time + swim_time * swim_level
##
##
func _process(delta: float) -> void:
	var player_pos = to_coords(player.position)
	var reset = Input.is_action_just_pressed("reset")
	var interact = Input.is_action_just_pressed("interact")
	
	if reset:
		respawn()
	
	if interact:
		if player_pos in checkpoint_coords:
			#
			pass
	
	# Check if there are blocks in water
	#if tilemap.get_cell_atlas_coords(to_coords($Block.position)).y in water_tiles:
		#$Block.in_water = true
	#else: 
		#$Block.in_water = false
	## Check if player standing on blocks
	#if player.position == $Block.position:
		#time_in_water = 0
	
	# Increase timer
	if tilemap.get_cell_atlas_coords(player_pos).y in water_tiles:
		time_in_water += delta
		if tilemap_above.get_cell_atlas_coords(player_pos).y in stand_tiles:
			time_in_water = 0
	else:
		time_in_water = 0

	# Respawn player in water after too long
	if time_in_water >= max_water_time:
		respawn()
