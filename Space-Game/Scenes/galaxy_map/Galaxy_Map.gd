extends Node

################################################################################
################################################################################
############                        Variables                       ############
################################################################################
################################################################################

signal ArrivedAtSystem

# Gets variables for accessing nodes in the hierarchy
onready var line_2d : Line2D = $Line2D
onready var ship : Sprite = $Ship
onready var cam : Camera2D = $Camera2D
onready var tPanel : ColorRect = $tPaneSlave/TPanel
onready var tPanelSlave : Node2D = $tPaneSlave
onready var sectorLabel : Label = $CanvasLayer/Sector
onready var plotLabel : Label = $CanvasLayer/PlotInfo
onready var container : Node2D = $ClusterContainer

# For Drawing Clusters and Stars
var clusterOffset
var clusters := []
var drawnClusters := []

# For the movement and tracking of the player and stars
var currentClusterID := Vector2.ZERO
var targetClusterID : Vector2

var plotStar : Area2D
var plotContainer := PoolVector2Array([])
var plotActive = false

var targetStar : Area2D = Area2D.new()			# Object of the targeted star
var targetStarID : Vector2						# ID of the targeted star (within the cluster object)
var targetStarGlobal : Vector2					# Global position of the target star

var currentStar : Area2D = Area2D.new()			# Current STar Object
var currentStarID : Vector2						# ID of the current Star
var currentStarGlobal : Vector2					# Global Position of the current star

# Ship 
var shipLocation
var isInSystem := false
var shipRadius := 1000.0
var shipRadiusWait := false

export var speed := 250
var limit
var potentialStars = []

var lNodes = []

var shipMoving = false
var mSpeed = 2.0
var canPlot = false

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
	
	var cStar = getStarObject(currentClusterID,currentStarID)
	currentStar = cStar
	targetStar = currentStar
	
	# Temp for default system
	var tCStar = getStarObject(Vector2(0,0),Global.defaultSystems["destSystem"]["coord"])
	QuestSystem.initialize(self)
	QuestSystem.set_dest(tCStar.global_position)
	
	setCurrentStarLocation()
	setTargetStarLocation() 
	updateLabel()
	
			
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
	for x in $potentialContainer.get_children():
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
		$potentialContainer.add_child(line, true)

func highlightStar(star):
	targetStar = star
	setTargetStarLocation()
	print("DISTANCE TO LOCATION : ", targetStar.global_position.distance_to(currentStarGlobal))
	match star in potentialStars:
		true:
			print("Star is in potential stars")
			line_2d.points = PoolVector2Array([targetStarGlobal, ship.position])
			line_2d.show()
			updateSystemPanel(star)
		false:
			plotStar = star
			print("star is outside potential stars")
			canPlot = true
			updateSystemPanel(star, false)
		
# When arrived at location, set current position as the target position and update destinations
func arrivedAtStar():
	shipMoving = false
	currentStar = targetStar
	setCurrentStarLocation()
	searchCells()
	if plotStar == currentStar:
		plotActive = false
		erasePlot()
		
		## DO SOMETHING NOW THAT YOU'RE THERE
	
	if plotActive:
		plotRoute()
	updateLabel()
	cam.position = cam.correctVector(ship.position, cam.limits)
	emit_signal("ArrivedAtSystem", currentStar.global_position)
	
# Updates the system panel and sets the information to the systems
func updateSystemPanel(star : Area2D, canTravel := true):
	tPanelSlave.show()
	var _s : Galaxy.SolarSystem = star.star
	tPanelSlave.global_position = star.global_position + Vector2(10,0)
	$tPaneSlave/TPanel/PlanetNum.text = str("Planets : ",_s.planetNum)
	$tPaneSlave/TPanel/SystemName.text = _s.name
	match canTravel:
		true:
			$tPaneSlave/TPanel/PlotRoute.hide()
			$tPaneSlave/TPanel/Travel.show()
		false:
			$tPaneSlave/TPanel/PlotRoute.show()
			$tPaneSlave/TPanel/Travel.hide()
#	$TPanel/PlanetNum.text = str("No Data")
	cam._moveToLocation(star.global_position)

# Updates the label in the bottom to the cuurent coordinates
func updateLabel():
	#var cluster = str("Cluster : ",)
	sectorLabel.text = str("Sector : ",currentClusterID,"/",currentStarID)
	if plotActive:
		var _sName = plotStar.star.name
		var _jumps = plotContainer.size() - 1
		plotLabel.text = str("Destination System\t: ",_sName,"\nJumps to destination\t: ",_jumps)


################################################################################
################################################################################
############        Functions for Drawing Stars and Clusters        ############
################################################################################
################################################################################

func updateClusters():
	clusters.clear()
	for i in range(-Global.clusterLength,Global.clusterLength + 1):
		for j in range(-Global.clusterLength,Global.clusterLength + 1):
			var offset = Vector2(i,j)
			var cluster = currentClusterID + offset
			clusters.append(cluster)
	#print("Current Clusters : ",clusters)
	drawClusters()
	deleteClusters()
	pass

func drawClusters():
	var _c = load("res://Scenes/galaxy_map/cluster.tscn")
	var todraw = []
	for cluster in clusters:
		if !drawnClusters.has(cluster):
			if !Global.clusterContainer.has(cluster):
				continue
			drawnClusters.append(cluster)
			var _cluster = _c.instance()
			_cluster.getID(cluster)
			_cluster.position = cluster * Galaxy.clusterSize * Galaxy.cellSize - Vector2(clusterOffset,clusterOffset)
			_cluster.generateCluster()
			_cluster.name = str("c_",cluster)
			#print("Cluster : ",cluster,"\n\tPosition : ",_cluster.position)
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
	$tPaneSlave/TPanel/Travel.connect("pressed", self, "travelSystem")
	$tPaneSlave/TPanel/System.connect("pressed", self, "openSystemMap")
	$tPaneSlave/TPanel/Back.connect("pressed", self, "hidePanel")
	$tPaneSlave/TPanel/PlotRoute.connect("pressed", self, "plotRoute")

# Opens the system map
func openSystemMap():
	if currentStar == targetStar:
		print("Entering System map for : ",currentStar.name)
		Global.currentSystemID = currentStarID
		Global.currentClusterID = currentClusterID
		Global.currentGlobalCoords = currentStarGlobal
		if Global.clusterContainer[Global.currentClusterID].systems.has(Global.currentSystemID):
			var target_scene = load("res://Scenes/System_Panel/SystemPanel.tscn")
			var err = get_tree().change_scene_to(target_scene)	

# If the Travel Button is pressed, check if coordinates match
func travelSystem():
	if currentStar != targetStar:
		moveShip(targetStarGlobal)

func plotRoute(_targetStar : Area2D = null):
	var plotting = $Plotting/ColorRect
	if !canPlot:
		return
	
	var tStar
	var cStar = currentStar
	
	if _targetStar != null:
		if _targetStar != plotStar:
			plotStar = _targetStar
		tStar = _targetStar
	else:
		tStar = plotStar
	
	plotActive = true
	
	var newArea2D = Area2D.new()
	var newCollisionShape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	
	newArea2D.name = "searchRadius"
	newCollisionShape.name = "sRadiusCollider"
	
	var jumpDist = $Ship/Area2D/CollisionShape2D.shape.radius * ship.scale.x
	print("ship jump dist : ",jumpDist)
	
	var initDist = (cStar.global_position.distance_to(tStar.global_position)/2) + 100
	var initLoc = (cStar.global_position + tStar.global_position)/2
	
	# Creates the search radius
	newArea2D.position = initLoc
	circle.radius = initDist
	newCollisionShape.shape = circle
		
	add_child(newArea2D,true)
	var _sR : Area2D = get_node("searchRadius")
	_sR.add_child(newCollisionShape,true)
	var _cR : CollisionShape2D = _sR.get_node("sRadiusCollider")
	
	var cStarID
	var tStarID
	var route : PoolVector2Array = PoolVector2Array([])
	var plotted = false
	
	while route.size() == 0:
		var astar = AStar2D.new()
		_sR.global_position = _sR.global_position
		_cR.position = Vector2(0,0)
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		
		var potStars = _sR.get_overlapping_areas()
		
		for i in potStars.size():
			astar.add_point(i, potStars[i].global_position)
			match potStars[i]:
				tStar:
					tStarID = i
				cStar:
					cStarID = i
				
		for x in astar.get_points():
			var pool = astar.get_points()
			var _pLocation = astar.get_point_position(x)
			for y in pool:
				if !astar.are_points_connected(x, y) and y != x:
					if _pLocation.distance_to(astar.get_point_position(y)) <= jumpDist:
						astar.connect_points(x,y)
		
		var path = astar.get_point_path(cStarID,tStarID)
		
		if (path.size() == 0):
			_cR.shape.radius += 100.0
		else:
			route = path
	
	plotContainer = route
	
	print("route to star : ",route)
	_sR.queue_free()
	drawPlot(route)
	plotting.hide()
	
	updateLabel()

func drawPlot(plotLine : PoolVector2Array):
	erasePlot()
	var line = load("res://Scenes/galaxy_map/mapPlotLine.tscn").instance()
	line.name = "plot_line"
	line.points = plotLine
	line.show()
	$mapPlotContainer.add_child(line, true)
	
func erasePlot():
	for x in $mapPlotContainer.get_children():
		if "plot_line" in x.name:
			x.queue_free()

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

# Function for getting the object from Cluster and Star IDs
func getStarObject(clusterID : Vector2, starID : Vector2):
	var _cl = str("c_",clusterID)
	var _st = str("s_",starID)
	if $ClusterContainer.has_node(_cl):
		if $ClusterContainer.get_node(_cl).has_node(_st):
			return $ClusterContainer.get_node(_cl).get_node(_st)
	return null

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

# Returns the minimum value in an array
func min_arr(array):
	var min_val = array[0]
	for i in range(0,array.size()):
		min_val = min(min_val, array[i])
	return min_val

func _physics_process(delta):
	pass

func _on_Area2D_area_entered(area):
	pass # Replace with function body.
