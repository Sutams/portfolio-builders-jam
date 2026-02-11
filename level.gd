extends Node2D

# Not using tilemap because i dont know how to specifically check a tile
@onready var tilemap = $TileMapLayer

@onready var player = $Player
var player_pos
var x
var y

var rise = true
var tide_height = 3

# Tile row number
var deep_water = 0
var water = 1
var grass = 2
var sand = 3
var wood = 4
var rock = 5
var allowed_tiles = [grass, sand, wood]

#const deep_water = Color.DARK_BLUE
#const water = Color.BLUE
#const ground = Color.GREEN_YELLOW
#const rock = Color.DIM_GRAY
#var elevation_map = [[ground, ground, ground, ground, ground],
					 #[deep_water, water, ground, rock],
					 #[deep_water, water, ground],
					 #[deep_water, water, rock, rock]]

#const color_map = [ Color.DODGER_BLUE, Color.DEEP_SKY_BLUE, 
					#Color.FOREST_GREEN, Color.DARK_GREEN, 
					#Color.GRAY, Color.DIM_GRAY]
#var map = []
#var elevation_map = [[0,0,5,5,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0],
					 #[0,5,4,4,3,3,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0],
					 #[0,0,5,4,4,3,3,2,2,2,2,2,2,2,2,2,1,1,1,1,1,0,0],
					 #[0,1,1,2,3,2,3,3,3,3,3,3,3,3,3,3,2,1,1,1,1,1,0],
					 #[1,1,1,1,2,2,3,2,3,3,3,3,3,3,3,3,3,2,1,1,1,1,1],
					 #[1,1,1,1,1,2,2,2,3,3,3,1,3,3,3,3,3,3,2,1,1,1,1],
					 #[1,1,1,2,1,2,3,3,3,3,1,0,1,3,3,3,3,3,2,1,1,1,1],
					 #[1,1,1,1,1,1,2,3,3,3,3,1,3,3,3,3,3,3,2,1,1,1,1],
					 #[1,1,1,1,5,5,1,2,3,3,3,3,3,3,3,3,3,4,3,1,1,1,1],
					 #[0,1,1,5,4,4,3,2,3,3,3,3,3,3,3,4,4,4,5,4,1,1,0],
					 #[0,0,5,4,5,3,2,3,3,3,3,3,3,3,3,3,4,5,5,4,1,0,0],
					 #[0,0,5,4,5,2,2,2,2,2,2,2,2,2,2,2,1,4,4,1,0,0,0],
					 #[0,0,0,5,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0]]
#Make quick program to edit map and export array list of elevation map!!!


func _ready() -> void:
	# Duplicate "true" means any changes to map are not shared with elevation_map
	#map = elevation_map.duplicate(true)
	pass


func _process(delta: float) -> void:
	check_player()
	# should player script check this instead?
	pass


#func _draw() -> void:
	#for row in elevation_map.size():
		#for col in elevation_map[row].size():
			#draw_rect(Rect2(col*16,row*16,16,16),color_map[map[row][col]])


#func _on_tide_timer_timeout() -> void:
	#for row in map.size():
		#for col in map[row].size():
			#if rise:
				#if map[row][col] < 4 and map[row][col] <= elevation_map[row][col] and map[row][col] > 0:
					#map[row][col] -= 1 
			#else:
				#if map[row][col] < elevation_map[row][col] and map[row][col] >= 0:
					#if map[row][col] == elevation_map[row][col] - tide_height:
						#map[row][col] += 1
	#tide_height-=1
	#if tide_height == 0:
		#rise = !rise
		#tide_height = 3
	#queue_redraw()
	
func check_player():
	#player_pos = player.position/16-Vector2(.5,.5) # Conversión para tener coordenadas en int
	#x = int(player_pos.x)
	#y = int(player_pos.y)
	#if map[y][x] < 2 and not player.can_swim:
		#player.position = Vector2((2.5)*16,(1.5)*16) # Conversión opuesta para volver al spawn
		#print("respawn")
		pass
	
	# I can check the "type" of tilemap like this
	#print(tilemap.get_cell_atlas_coords(Vector2i(x,y)))
	# it returns i.e (0,0) or (3,1) which are the tiles on the *Atlas*


func _on_player_moving() -> void:
	# Converting player's NEXT position into tilemap coordinates
	player_pos = player.next_pos/16-Vector2(.5,.5) 
	x = int(player_pos.x)
	y = int(player_pos.y)
	var next_tilemap_position = Vector2i(x,y)
	
	# If next move is grass (~,2), player can move
	if tilemap.get_cell_atlas_coords(next_tilemap_position).y in allowed_tiles:
		player.valid_move = true
	else:
		player.valid_move = false
