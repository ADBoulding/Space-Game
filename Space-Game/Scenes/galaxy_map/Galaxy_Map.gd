extends Node

onready var line_2d : Line2D = $Line2D
onready var ship : Sprite = $Ship
onready var tile : TileMap = $TileMap
onready var cam : Camera2D = $Camera2D
onready var travelB : Button = $CanvasLayer/Control/Travel
onready var systemB : Button = $CanvasLayer/Control/System
onready var sLabel : Label = $CanvasLayer/Label

var isInSystem := false
var coordinates_curr : Vector2
var coordinates_dest : Vector2

var path : PoolVector2Array
var goal : Vector2
export var speed := 250
export (int, 1, 10) var searchRadius 
var limit
var shipLocation
var potentialStars = []

var lNodes = []

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	travelB.connect("button_down", self, "_travelSystem")
	systemB.connect("button_down", self, "_openSystemMap")
	searchRadius = 7
	var shipPos
	if Global.coordContainer.size() == 0:
		Global.init_system()
		shipPos = Vector2(-1,-1)
	else:
		coordinates_curr = Global.currentSystem
		coordinates_dest = coordinates_curr
		shipPos = _centerCoords(tile.map_to_world(coordinates_curr))
		travelB.show()
		systemB.show()
		
	init_galaxy(shipPos)
	
func init_galaxy(_dest := Vector2(-1,-1)):
	tile.make_map()
	cam._set_limits()
	limit = tile.get_used_rect()
	_move_and_set_ship(_dest)

func _move_and_set_ship(destination := Vector2(-1,-1)):
	if line_2d.visible:
		line_2d.hide()
	_changeSystem()
	_set_ship_loc(destination)
	_searchCells()
	_drawCells()
	_update_label()
	
func _changeSystem():
	for x in get_children():
		if "line_" in x.name:
			x.queue_free()
	lNodes.clear()
	
func _set_ship_loc(dest := Vector2(-1,-1)):
	if dest.x == -1 and dest.y == -1:
		var destMap = limit.end / 2
		var destWorld = _centerCoords(tile.map_to_world(destMap))
		ship.set_global_position(destWorld)
	else:
		ship.set_global_position(dest)
	coordinates_curr = tile.world_to_map(ship.position)
	cam.position = cam.correctVector(ship.position, cam.limits)

func _searchCells():
	var cMap = tile.current_map_size
	potentialStars = []
	var xRange = [max(0, coordinates_curr.x - searchRadius), min(cMap.x, coordinates_curr.x + searchRadius)]
	var yRange = [max(0, coordinates_curr.y - searchRadius), min(cMap.y, coordinates_curr.y + searchRadius)]
	
	for i in range(xRange[0],xRange[1]):
		for j in range(yRange[0],yRange[1]):
			if tile.get_cell(i,j) == tile.TILES.Star:
				potentialStars.append(Vector2(i,j))
	print(potentialStars)		
	
func _drawCells():
	print(lNodes)
	for star in potentialStars:
		var toScreen = tile.map_to_world(star)
		toScreen.x += 16
		toScreen.y += 16
		var line = load("res://Scenes/galaxy_map/potentialLine.tscn").instance()
		var pName = "line_" + str(star.x) + str(star.y)
		line.name = pName
		line.points = PoolVector2Array([toScreen, ship.position])
		line.show()
		add_child(line, true)
		lNodes.append(get_node(pName))
	print(lNodes)

func _update_label():
	sLabel.text = str("Sector:\n",coordinates_curr.x,"/",coordinates_curr.y)
	
func _highlightStar(_tile: Vector2):
	var _nTile = tile.map_to_world(_tile)
	_nTile = _centerCoords(_nTile)
	line_2d.points = PoolVector2Array([_nTile, ship.position])
	line_2d.show()
	
func _centerCoords(vec: Vector2):
	var vecAdj = vec
	vecAdj.x += (tile.cell_size.x / 2)
	vecAdj.y += (tile.cell_size.y / 2)
	return vecAdj

func _travelSystem():
	if coordinates_curr != coordinates_dest:
		var tVec = tile.map_to_world(coordinates_dest)
		tVec = _centerCoords(tVec)
		_move_and_set_ship(tVec)
		systemB.show()
		
func _openSystemMap():
	if coordinates_curr in Global.coordContainer:
		print("Let's a go!!")
		if Global.currentSystem != coordinates_curr:
			Global.currentSystem = coordinates_curr
		var target_scene = load("res://Scenes/System_Map.tscn")
		var err = get_tree().change_scene_to(target_scene)	
		
func _unhandled_input(event: InputEvent):
	if not event is InputEventMouseButton:
		return
	if event.button_index != BUTTON_LEFT or not event.pressed:
		return
	print("mouse Click!")
	var viewPos = tile.world_to_map(event.position - Vector2(320,180) + cam.position)
	var cellType = tile.get_cellv(viewPos)
	
	if cellType == tile.TILES.Star:
		if 	viewPos in potentialStars:
			print("SHOULD BE VIS")
			coordinates_dest = viewPos
			if coordinates_curr != coordinates_dest:
				travelB.visible = true
	
func _process(delta: float) -> void:
	var rawMouse = get_viewport().get_mouse_position()
	var mousePos = tile.world_to_map(rawMouse - Vector2(320,180) + cam.position)
	var mouseTile = tile.get_cellv(mousePos)
	if mouseTile == tile.TILES.Star:
		if mousePos in potentialStars:
			_highlightStar(mousePos)
