extends TileMap

enum TILES {Space, Star}

var current_map_size
var map

var ship

func make_map():
	current_map_size = Vector2(Global.mapSize,Global.mapSize)
	map = Global.systemMapArray
	print ("map is : " + str(current_map_size.x) + "x" + str(current_map_size.y))
	for x in range(0, current_map_size.x):
		for y in range(0, current_map_size.y):
			set_cell(x,y, map[x][y])
	update_dirty_quadrants()
	
