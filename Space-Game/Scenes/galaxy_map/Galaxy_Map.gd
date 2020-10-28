extends Node

################################################################################
################################################################################
############                        Variables                       ############
################################################################################
################################################################################

# Gets variables for accessing nodes in the hierarchy
onready var line_2d : Line2D = $Line2D
onready var ship : Sprite = $Ship
onready var cam : Camera2D = $Camera2D
onready var tPanel : ColorRect = $tPaneSlave/TPanel
onready var tPanelSlave : Node2D = $tPaneSlave
onready var sLabel : Label = $CanvasLayer/Label
onready var container : Node2D = $ClusterContainer

# For Drawing Clusters and Stars
var clusterOffset
var clusters := []
var drawnClusters := []

# For the movement and tracking of the player and stars
var currentClusterID := Vector2.ZERO
var targetClusterID : Vector2

var targetStar : Area2D = Area2D.new()			# Object of the targeted star
var targetStarID : Vector2						# ID of the targeted star (within the cluster object)
var targetStarGlobal : Vector2					# Global position of the target star

var currentStar : Area2D = Area2D.new()			# Current STar Object
var currentStarID : Vector2						# ID of the current Star
var currentStarGlobal : Vector2					# Global Position of the current star

# Ship 
var shipLocation
var isInSystem := false

export var speed := 250
export (int, 1, 10) var searchRadius 
var limit
var potentialStars = []

var lNodes = []

var shipMoving = false
var mSpeed = 2.0

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	clusterOffset = Galaxy.cellSize * Galaxy.clusterSize / 2
	setButtonSignals()
	var shipPos
	match Global.clusterContainer.size():
		0:
			Global.init_system()
			currentClusterID = Vector2.ZERO
			currentStarID = Galaxy.startSystem
			shipPos = null
		_:
			currentClusterID = Global.currentClusterID
			currentStarID = Global.currentSystemID
			shipPos = Global.currentGlobalCoords
	init_galaxy(shipPos)

func _process(delta):
	if !shipMoving:
		return
	var timeLerped = 0
	timeLerped += delta 
	if buffer(ship.global_position, targetStarGlobal, 0.1):
		timeLerped = 0
		arrivedAtStar()
		return
	ship.global_position = ship.global_position.linear_interpolate(targetStarGlobal, timeLerped/0.25)	

func init_galaxy(_dest):
	cam._set_limits(currentClusterID)
	updateClusters()
	var initDest
	match _dest:
		null:
			initDest = Vector2(0,0)
		_:
			initDest = _dest
	cam.position = initDest
	ship.set_global_position(initDest)
	
	var _cName = str("c_",currentClusterID)
	var _sName = str("s_",currentStarID)
	var cStar = container.get_node(_cName).get_node(_sName)
	currentStar = cStar
	targetStar = currentStar
	setCurrentStarLocation()
	setTargetStarLocation() 
			

# Initializes the Search after everthything is ready in the scene.
func _on_Camera2D_CanUpdate():
	searchCells()
	pass # Replace with function body.

################################################################################
################################################################################
############      Functions for Ship and Travel Functionality       ############
################################################################################
################################################################################

func moveShip(dest : Vector2):
	eraseLines()
	if dest != currentStarGlobal:
		shipMoving = true
	
func eraseLines():
	if line_2d.visible:
		line_2d.hide()
	for x in get_children():
		if "line_" in x.name:
			x.queue_free()

func searchCells():
	var shipRad = ship.get_node("Area2D")
	if !potentialStars == shipRad.get_overlapping_areas():
		potentialStars = shipRad.get_overlapping_areas()
		drawCells()

func drawCells():
	for star in potentialStars:
		var toScreen = star.global_position
		var line = load("res://Scenes/galaxy_map/potentialLine.tscn").instance()
		var pName = "line_" + str(toScreen.x) + str(toScreen.y)
		line.name = pName
		line.points = PoolVector2Array([toScreen, ship.position])
		line.show()
		add_child(line, true)

func highlightStar(star):
	if star in potentialStars:
		print("Star is in potential stars")
		targetStar = star
		setTargetStarLocation()
		line_2d.points = PoolVector2Array([targetStarGlobal, ship.position])
		line_2d.show()
		updateSystemPanel(targetStarGlobal)
		
# When arrived at location, set current position as the target position and update destinations
func arrivedAtStar():
	shipMoving = false
	currentStar = targetStar
	setCurrentStarLocation()
	searchCells()
	updateLabel()
	cam.position = cam.correctVector(ship.position, cam.limits)
	
# Updates the system panel and sets the information to the systems
func updateSystemPanel(dest : Vector2):
	tPanelSlave.show()
	var _s : Galaxy.SolarSystem = targetStar.star
	tPanelSlave.global_position = dest + Vector2(10,0)
	$tPaneSlave/TPanel/PlanetNum.text = str("Planets : ",_s.planetNum)
	$tPaneSlave/TPanel/SystemName.text = _s.name
#	$TPanel/PlanetNum.text = str("No Data")
	#cam._moveToLocation(_centerCoords(tile.map_to_world(dest)))

# Updates the label in the bottom to the cuurent coordinates
func updateLabel():
	#var cluster = str("Cluster : ",)
	sLabel.text = str("Cluster : ",currentClusterID.x,"/",currentClusterID.y,"\nSector : ",currentStarID.x,"/",currentStarID.y)


################################################################################
################################################################################
############        Functions for Drawing Stars and Clusters        ############
################################################################################
################################################################################

func updateClusters():
	clusters.clear()
	for i in [-2,-1,0,1,2]:
		for j in [-2,-1,0,1,2]:
			var offset = Vector2(i,j)
			var cluster = currentClusterID + offset
			clusters.append(cluster)
	print("Current Clusters : ",clusters)
	drawClusters()
	deleteClusters()
	pass

func drawClusters():
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
			print("Cluster : ",cluster,"\n\tPosition : ",_cluster.position)
			container.add_child(_cluster, true)
	for child in container.get_children():
		for star in child.get_children():
			star.connect("clickedOn", self, "highlightStar", [star])
	pass

func deleteClusters():
	for cluster in drawnClusters:
		if !clusters.has(cluster):
			container.get_node(str("c_",cluster)).queue_free()
			drawnClusters.remove(drawnClusters.find(cluster))


################################################################################
################################################################################
############                       Buttons!!                        ############
################################################################################
################################################################################

func setButtonSignals():
	$tPaneSlave/TPanel/Travel.connect("button_down", self, "travelSystem")
	$tPaneSlave/TPanel/System.connect("button_down", self, "openSystemMap")
	$tPaneSlave/TPanel/Back.connect("button_down", self, "hidePanel")

# Opens the system map
func openSystemMap():
	if currentStar == targetStar:
		print("Entering System map for : ",currentStar.name)
		Global.currentSystemID = currentStarID
		Global.currentClusterID = currentClusterID
		Global.currentGlobalCoords = currentStarGlobal
		if Global.clusterContainer[Global.currentClusterID].systems.has(Global.currentSystemID):
			var target_scene = load("res://Scenes/solar_system/System_Map.tscn")
			var err = get_tree().change_scene_to(target_scene)	

# If the Travel Button is pressed, check if coordinates match
func travelSystem():
	if currentStar != targetStar:
		moveShip(targetStarGlobal)

# Hides the panel
func hidePanel():
	tPanelSlave.hide()
	
# Temp script for if you click on the search radius
func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		pass

################################################################################
################################################################################
############                     UTILITIES!!                        ############
################################################################################
################################################################################

# Gets target star data from object
func setTargetStarLocation():
	var star = targetStar
	targetStarID = stripName(star.name)
	targetStarGlobal = star.global_position
	targetClusterID = stripName(star.get_parent().name)

# Gets local star Data from object
func setCurrentStarLocation():
	var star = currentStar
	currentStarID = stripName(star.name)
	currentStarGlobal = star.global_position
	currentClusterID = stripName(star.get_parent().name)
	
# Strips the name of the Star or the Cluster and return the ID as a vector2!!!
func stripName(name := ""):
	var dest
	var val
	if "c" in name:
		val = name.lstrip("c_(").rstrip(")").split(",")
		dest = Vector2(float(val[0]),float(val[1]))
	elif "s" in name:
		val = name.lstrip("s_(").rstrip(")").split(",")
		dest = Vector2(float(val[0]),float(val[1]))
	return dest
	
# Gets the amount of stars currently drawn
func countStars():
	var count = 0
	for cluster in container.get_children():
		count += cluster.get_child_count()
	print(count)
	
# Checks if the Object is within a specific buffer distance to the destination
func buffer(at : Vector2, dest : Vector2, buffer: float):
	if dest.x-at.x < buffer and dest.x-at.x > -buffer:
		if dest.y-at.y < buffer and dest.y-at.y > -buffer:
			return true
	return false




func _on_Area2D_area_entered(area):
	pass # Replace with function body.
