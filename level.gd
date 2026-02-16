extends Node2D

@onready var tilemap = $TileMapLayer
@onready var tide_timer = $TideTimer
@onready var player = $Player

const TILE_SIZE = 16
const OFFSET = Vector2(.5,.5)

var rise : bool
var tide_height
var max_tide

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


func _ready() -> void:
	# Initialize variables
	tide_height = 0
	rise = true
	
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


func _process(_delta: float) -> void:
	pass


## Manages the rise and lowering of the tides by changing the tilemap
func _on_tide_timer_timeout() -> void:
	print("rise ", rise, " tide_height ", tide_height)
	# Cycle through whole tilemap
	var used_cells = tilemap.get_used_cells()
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
	# Converting player's NEXT position into tilemap coordinates
	var next_tilemap_position = Vector2i((player.next_pos / TILE_SIZE) - OFFSET)	
	
	# Check if next move is allowed based on tile's Y-coord on atlas tilemap
	if tilemap.get_cell_atlas_coords(next_tilemap_position).y in allowed_tiles:
		player.valid_move = true
	else:
		player.valid_move = false
