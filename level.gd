extends Node2D

# Not using tilemap because i dont know how to specifically check a tile
@onready var tilemap = $TileMapLayer
var tilemap_copy : TileMapLayer

@onready var player = $Player
var player_pos
var x
var y

var rise = true
var tide_height
var max_tide

# Tile row number
var deep_water = 0
var water = 1
var grass = 2
var sand = 3
var wood = 4
var rock = 5
var allowed_tiles = [grass, sand, wood]


func _ready() -> void:
	# Duplicate of tilemap
	tilemap_copy = TileMapLayer.new()
	tilemap_copy.set_tile_map_data_from_array(tilemap.get_tile_map_data_as_array())
	
	# Sets how high the water will get based on
	# how many tiles in the X-axis are in the tileset 
	# (every row should have the same amount!)
	max_tide = 0
	var used_cells = tilemap.get_used_cells()
	for cell in used_cells:
		var tile = tilemap.get_cell_atlas_coords(cell)
		if tile.x > max_tide:
			max_tide = tile.x
	tide_height = 0
	pass

func _process(_delta: float) -> void:
	pass


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
				tilemap.set_cell(cell, 0 , Vector2i(max_tide, water))
			# if already water, change its color to deeper water
			elif tile.x > 0 and tile.y == water:
				tilemap.set_cell(cell, 0 , Vector2i(tile.x-1, water))
		else:
			# slowly go back to normal
			if tile_copy.x == tide_height-1 and tile_copy.y in allowed_tiles:
				tilemap.set_cell(cell, 0 , tile_copy)
			# if next time its gonna be normal then change the water color
			elif tile.y == water and tile_copy.y in allowed_tiles:
				tilemap.set_cell(cell, 0 , Vector2i(tile.x+1, water))
			# make water clearer till its back to normal
			elif tile_copy.y == water and tile.x < tile_copy.x:
				tilemap.set_cell(cell, 0 , Vector2i(tile.x+1, water))
	# Rises and lowers the tide
	if rise:
		tide_height+=1
	else:
		tide_height-=1
	if tide_height == 0 or tide_height == max_tide:
		rise = !rise


# I can check the "type" of tile in the tilemap with the function
# tilemap.get_cell_atlas_coords(Vector2i(x,y))
# it returns e.g. (0,0) or (3,1) which are the tiles on the *Atlas*
func _on_player_moving() -> void:
	# Converting player's NEXT position into tilemap coordinates
	player_pos = player.next_pos/16-Vector2(.5,.5) 
	x = int(player_pos.x)
	y = int(player_pos.y)
	var next_tilemap_position = Vector2i(x,y)
	#print("player is at position ", next_tilemap_position)
	#print("on atlas is ", tilemap.get_cell_atlas_coords(next_tilemap_position))
	
	# If next move is e.g. grass=(~,2), player can move
	if tilemap.get_cell_atlas_coords(next_tilemap_position).y in allowed_tiles:
		player.valid_move = true
	else:
		player.valid_move = false
