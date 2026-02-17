extends Node2D

@onready var tilemap = $TileMapLayer
@onready var tide_timer = $TideTimer
@onready var player = $Player
@onready var camera = $Camera2D
@onready var area_camera = $Camera2D/AreaCamera

const CAM_X_OFFSET = 23
const CAM_Y_OFFSET = 13
const TILE_SIZE = 16
const OFFSET = Vector2(.5,.5)
const MAX_WATER_TIME = 0.2

var camera_origin : Vector2
var camera_vector = Vector2.ZERO
var time_in_water : float
var rise : bool
var tide_height : int
var max_tide : int

var tilemap_copy : TileMapLayer
const type = { "Deep Water" : 0, # <- Tilemap atlas Y-coord
				"Water" : 1,
				"Grass" : 2,
				"Sand" : 3,
				"Wood" : 4,
				"Rock" : 5
			}
# List of tiles the player can move on
var allowed_tiles = [type["Grass"], type["Sand"], type["Wood"]]
var water_tiles = [type["Deep Water"], type["Water"]]

##
##
func _ready() -> void:
	# Initialize variables
	tide_height = 0
	rise = true
	time_in_water = 0
	camera_origin = camera.position
	
	# Create copy tilemap to keep track of original values
	tilemap_copy = TileMapLayer.new()
	tilemap_copy.set_tile_map_data_from_array(tilemap.get_tile_map_data_as_array())
	
	# Automatically determines how much the water rises
	# based on max n° of tiles in the X-axis
	# (every row should have the same amount!)
	max_tide = 0
	var used_cells = tilemap.get_used_cells()
	for cell in used_cells:
		var tile = tilemap.get_cell_atlas_coords(cell)
		if tile.x > max_tide:
			max_tide = tile.x

## Converts a position into tilemap coordinates
func to_coords(pos: Vector2) -> Vector2i:
	return Vector2i((pos / TILE_SIZE) - OFFSET)

##
##
func _process(delta: float) -> void:
	var player_pos = to_coords(player.position)
	
	# Check if there are blocks in water
	if tilemap.get_cell_atlas_coords(to_coords($Block.position)).y in water_tiles:
		$Block.in_water = true
	else: 
		$Block.in_water = false
	# Check if player standing on blocks
	if player.position == $Block.position:
		time_in_water = 0
	
	# Increase timer
	if tilemap.get_cell_atlas_coords(player_pos).y in water_tiles:
		time_in_water += delta
	else:
		time_in_water = 0
	# Respawn player in water after too long
	if time_in_water >= MAX_WATER_TIME:
		player.position = $Checkpoint.position
		camera_vector.x = 0
		camera_vector.y = 0

## Manages the rise and lowering of the tides by changing the tilemap
##
func _on_tide_timer_timeout() -> void:
	var used_cells = tilemap.get_used_cells()
	# Cycle through whole tilemap
	for cell in used_cells:
		var tile = tilemap.get_cell_atlas_coords(cell)
		var tile_copy = tilemap_copy.get_cell_atlas_coords(cell)
		if rise:
			# slowly turn into water
			if tile.x == tide_height and tile.y in allowed_tiles:
				tilemap.set_cell(cell, 0 , Vector2i(max_tide, type["Water"]))
			# if already water, change its color to deeper water
			elif tile.x > 0 and tile.y == type["Water"]:
				tilemap.set_cell(cell, 0 , Vector2i(tile.x-1, type["Water"]))
			elif tile.x > 0 and tile.y == type["Deep Water"]:
				tilemap.set_cell(cell, 0 , Vector2i(tile.x-1, type["Deep Water"]))
		else:
			# slowly go back to normal
			if tile_copy.x == tide_height-1 and tile_copy.y in allowed_tiles:
				tilemap.set_cell(cell, 0 , tile_copy)
			# if next time the tile is gonna be back to normal then change the water color
			elif tile.y == type["Water"] and tile_copy.y in allowed_tiles:
				tilemap.set_cell(cell, 0 , Vector2i(tile.x+1, type["Water"]))
			# make water clearer till its back to normal
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
		
		# Stop tide movement for a short time
		tide_timer.paused = true
		await get_tree().create_timer(randi_range(1,5)).timeout
		tide_timer.paused = false

## I can check the "type" of tile in the tilemap with the function
## tilemap.get_cell_atlas_coords(Vector2i(x,y))
## it returns e.g. (0,0) or (3,1) which are the tiles on the *Atlas*
func _on_player_moving() -> void:
	#var next_tilemap_position = to_coords(player.next_pos)
	## Check if next move is allowed based on tile's Y-coord on atlas tilemap
	#if tilemap.get_cell_atlas_coords(next_tilemap_position).y in allowed_tiles:
		#player.valid_move = true
	#elif player.next_pos == $Block.position:
	player.valid_move = true
	#else:
		#player.valid_move = false
	pass

## Moves the camera depending on players direction
##
func _on_area_camera_area_exited(area: Area2D) -> void:
	if area.is_in_group("player"):
		print("area.direction ", area.direction)
		print("camera_vector ", camera_vector)
		camera_vector.x += area.direction.x
		camera_vector.y += area.direction.y
		print("after sum ", camera_vector)
		camera.position.x = camera_origin.x + camera_vector.x * TILE_SIZE * CAM_X_OFFSET
		camera.position.y = camera_origin.y + camera_vector.y * TILE_SIZE * CAM_Y_OFFSET
		# Gives small to avoid area moving bug
		area_camera.set_deferred("monitoring",false)
		await get_tree().create_timer(.1).timeout
		area_camera.set_deferred("monitoring",true)
