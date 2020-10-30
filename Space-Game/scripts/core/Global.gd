"""
Global project script. 
Handles:
	RNG
	Location
	Galaxy (i.e. Clusters, systems, planets)
"""
extends Node

signal enteredSystem
signal enteredGalaxyMap

var rng = RandomNumberGenerator.new()
onready var windowSize = Vector2(ProjectSettings.get_setting("display/window/size/width"),ProjectSettings.get_setting("display/window/size/height"))

var defaultSystems = {}

var CurrentLocation = {
	"cluster" : Vector2.ZERO,
	"system" : Galaxy.startSystem,
	"planet" : -1
}

var clusterContainer = {}
var discoveredSystems = []

var clusterLength = 3

var currentSystemID := Vector2.ZERO
var currentClusterID := Vector2.ZERO

var currentGlobalCoords := Vector2.ZERO

var planetNum = 0
var systemNum = 0

func randomizeRNG():
	rng.randomize()

func addCluster(clusterID := Vector2.ZERO, clusterName := ""):
	if !clusterContainer.has(clusterID):
		clusterContainer[clusterID] = Galaxy.Cluster.new(clusterID, clusterName)

func init_system():
	resetSystem()
	loadDefaultSystems()
	print("planets: " + str(planetNum))
	print("systems: " + str(systemNum))
			
func resetSystem():
	planetNum = 0
	systemNum = 0
	clusterContainer.clear()
	for i in range(-clusterLength,clusterLength + 1):
		for j in range(-clusterLength,clusterLength + 1):
			addCluster(Vector2(i,j))
			
func loadDefaultSystems():
	var filePath = "res://Files/defaultSystems.json"
	var file = File.new()
	if not file.file_exists(filePath):
		print("AWE SHIIIIIIT")
		return
		
	print("FILE EXISTS")
	file.open(filePath, file.READ)
	
	var text = file.get_as_text()
	var data = JSON.parse(text).result
	file.close()
	
	for sys in data:
		var system = Galaxy.SolarSystem.new("",0,false)
		var jumpDist = data[sys]["jumpRange"]
		system._loadFromJSON(data[sys])
		defaultSystems[sys] = {
			"system" : system,
			"jumpRange" : int(jumpDist)
		}
		
#	for system in defaultSystems:
#		print(defaultSystems[system]["system"].name,", ",defaultSystems[system]["jumpRange"])
#		if system == "startingSystem":
#			clusterContainer[Vector2(0,0)].systems[Galaxy.startSystem] = defaultSystems[system]["system"]
#		elif system == "destSystem":
#			var coords = clusterContainer[Vector2(0,0)].systems.keys()
#			var coord = coords[Global.rng.randi_range(0,coords.size())]
#			print(coord)
#			clusterContainer[Vector2(0,0)].systems[coord] = defaultSystems[system]["system"]


func loadSystemFromDefaults(_sys:String, _coord:Vector2):
	pass
