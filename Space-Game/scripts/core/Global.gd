extends Node

var rng = RandomNumberGenerator.new()
onready var windowSize = Vector2(ProjectSettings.get_setting("display/window/size/width"),ProjectSettings.get_setting("display/window/size/height"))

var clusterContainer = {}

var coordContainer = []
var systemDictionary = {}
var discoveredSystems = []

var currentSystem := Vector2.ZERO
var currentCluster := Vector2.ZERO

var currGlobalCoords := Vector2.ZERO

var currSys : Galaxy.SolarSystem
var currClust : Galaxy.Cluster

var planetNum = 0
var systemNum = 0

func randomizeRNG():
	rng.randomize()

func addCluster(clusterID := Vector2.ZERO, clusterName := ""):
	if !clusterContainer.has(clusterID):
		clusterContainer[clusterID] = Galaxy.Cluster.new(clusterID, clusterName)

func init_system():
	resetSystem()
	currClust = clusterContainer[currentCluster]
	print("planets: " + str(planetNum))
	print("systems: " + str(systemNum))
			
func resetSystem():
	planetNum = 0
	systemNum = 0
	clusterContainer.clear()
	for i in [-1,0,1]:
		for j in [-1,0,1]:
			addCluster(Vector2(i,j))
