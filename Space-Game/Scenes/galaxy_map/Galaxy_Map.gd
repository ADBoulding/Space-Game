extends Node

onready var line_2d : Line2D = $Line2D
onready var ship : Sprite = $Ship
onready var cam : Camera2D = $Camera2D
onready var tPanel : ColorRect = $tPaneSlave/TPanel
onready var tPanelSlave : Node2D = $tPaneSlave
onready var sLabel : Label = $CanvasLayer/Label
onready var container : Node2D = $ClusterContainer

var clusterOffset

var currCluster := Vector2.ZERO
var currCoords : Vector2
var destCluster := Vector2.ZERO
var destCoords : Vector2
var global_curr : Vector2
var global_dest : Vector2

var clusters := []
var drawnClusters := []

var targetStar : Area2D
var currentStar : Area2D

var dCluster : Vector2
var dStar : Vector2

var isInSystem := false

var path : PoolVector2Array
var goal : Vector2
export var speed := 250
export (int, 1, 10) var searchRadius 
var limit
var shipLocation
var potentialStars = []

var lNodes = []

var shipMoving
var mSpeed = 2.0

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	clusterOffset = Galaxy.cellSize * Galaxy.clusterSize / 2
	$tPaneSlave/TPanel/Travel.connect("button_down", self, "_travelSystem")
	$tPaneSlave/TPanel/System.connect("button_down", self, "_openSystemMap")
	$tPaneSlave/TPanel/Back.connect("button_down", self, "_hidePanel")
	searchRadius = 7
	var shipPos
	if Global.clusterContainer.size() == 0:
		Global.init_system()
		shipPos = Vector2.ZERO
		init_galaxy(shipPos)
	else:
		currCoords = Global.currentSystem
		shipPos = Global.currGlobalCoords
		ship.global_position = shipPos
		destCoords = currCoords
		cam._set_limits(currCluster)
		cam.position = shipPos
		update_clusters()
	
func init_galaxy(_dest := Vector2(-1,-1)):
	cam._set_limits(currCluster)
	cam.position = _dest
	update_clusters()
	_move_and_set_ship(_dest)

func update_clusters():
	clusters.clear()
	for i in [-1,0,1]:
		for j in [-1,0,1]:
			var offset = Vector2(i,j)
			var cluster = currCluster + offset
			clusters.append(cluster)
	print(clusters)
	draw_clusters()
	delete_clusters()
	pass

func draw_clusters():
	var _c = load("res://Scenes/galaxy_map/cluster.tscn")
	var todraw = []
	for cluster in clusters:
		if !drawnClusters.has(cluster):
			drawnClusters.append(cluster)
			var _cluster = _c.instance()
			_cluster.getID(cluster)
			_cluster.position = cluster * Galaxy.clusterSize * Galaxy.cellSize - Vector2(clusterOffset,clusterOffset)
			_cluster.generateCluster()
			_cluster.name = str("c_",cluster)
			container.add_child(_cluster, true)
	for child in container.get_children():
		for star in child.get_children():
			star.connect("clickedOn", self, "_highlightStar", [star])
	pass

func delete_clusters():
	for cluster in drawnClusters:
		if !clusters.has(cluster):
			container.get_node(str("c_",cluster)).queue_free()
			drawnClusters.remove(drawnClusters.find(cluster))

func _move_and_set_ship(destination := Vector2(-1,-1)):
	if line_2d.visible:
		line_2d.hide()
	_changeSystem()
	_set_ship_loc(destination)
#
func _changeSystem():
	for x in get_children():
		if "line_" in x.name:
			x.queue_free()
	lNodes.clear()

func _set_ship_loc(dest := Vector2(-1,-1)):
	if dest == Vector2(-1,-1):
		ship.set_global_position(Vector2(0,0))
	else:
		shipMoving = true
	currCoords = destCoords

func _searchCells():
	var shipRad = ship.get_node("Area2D")
	if !potentialStars == shipRad.get_overlapping_areas():
		potentialStars = shipRad.get_overlapping_areas()
		_changeSystem()
		_drawCells()

func _drawCells():
	lNodes = []
	for star in potentialStars:
		var toScreen = star.global_position
		var line = load("res://Scenes/galaxy_map/potentialLine.tscn").instance()
		var pName = "line_" + str(toScreen.x) + str(toScreen.y)
		line.name = pName
		line.points = PoolVector2Array([toScreen, ship.position])
		line.show()
		add_child(line, true)
		lNodes.append(get_node(pName))
	print(lNodes)

func _update_label():
	sLabel.text = str("Sector:\n",currCoords.x,"/",currCoords.y)

func _highlightStar(star):
	if star in potentialStars:
		print("working?")
		var _nStar = star.global_position
		destCluster = _stripName(star.get_parent().name)
		destCoords = _stripName(star.name)
		global_dest = star.global_position
		targetStar = star
		if !currentStar:
			currentStar = targetStar
		line_2d.points = PoolVector2Array([_nStar, ship.position])
		line_2d.show()
		_updateSystemPanel(_nStar)

func _stripName(name := ""):
	var dest
	var val
	if "c" in name:
		val = name.lstrip("c_(").rstrip(")").split(",")
		dest = Vector2(float(val[0]),float(val[1]))
	elif "s" in name:
		val = name.lstrip("s_(").rstrip(")").split(",")
		dest = Vector2(float(val[0]),float(val[1]))
	return dest
		
func _travelSystem():
	if currCoords != destCoords:
		_move_and_set_ship(global_dest)

func _openSystemMap():
	if currentStar == targetStar:
		print("Let's a go!!")
		Global.currSys = currentStar.star
		currCoords = _stripName(currentStar.name)
		Global.currentSystem = currCoords
		Global.currentCluster = currCluster
		Global.currGlobalCoords = ship.global_position
		if Global.clusterContainer[Global.currentCluster].systems.has(currCoords):
			var target_scene = load("res://Scenes/System_Map.tscn")
			var err = get_tree().change_scene_to(target_scene)	

func _updateSystemPanel(dest : Vector2):
	tPanelSlave.show()
	var _s : Galaxy.SolarSystem = targetStar.star
	tPanelSlave.global_position = dest + Vector2(10,0)
	$tPaneSlave/TPanel/PlanetNum.text = str("Planets : ",_s.planetNum)
	$tPaneSlave/TPanel/SystemName.text = _s.name
#	$TPanel/PlanetNum.text = str("No Data")
	#cam._moveToLocation(_centerCoords(tile.map_to_world(dest)))

func _hidePanel():
	tPanelSlave.hide()

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		pass
		
func _on_Area2D_area_entered(area):
	pass
	#print("TRUEEEEE")

func countStars():
	var count = 0
	for cluster in container.get_children():
		count += cluster.get_child_count()
	print(count)
		
func _on_Camera2D_CanUpdate():
	_searchCells()
	pass # Replace with function body.

func buffer(at : Vector2, dest : Vector2, buffer: float):
	if dest.x-at.x < buffer and dest.x-at.x > -buffer:
		if dest.y-at.y < buffer and dest.y-at.y > -buffer:
			return true
	return false

func _process(delta):
	if shipMoving:
		if buffer(ship.global_position, global_dest, 0.1):
			shipMoving = false
			global_dest = ship.global_position
			currentStar = targetStar
			_searchCells()
			_drawCells()
			_update_label()
			cam.position = cam.correctVector(ship.position, cam.limits)
			return
		var vecs = Vector2(lerp(ship.global_position.x,global_dest.x,mSpeed * delta),lerp(ship.global_position.y,global_dest.y,mSpeed * delta))
		ship.global_position = vecs
