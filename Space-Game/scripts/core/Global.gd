extends Node

var rng = RandomNumberGenerator.new()
onready var windowSize = Vector2(ProjectSettings.get_setting("display/window/size/width"),ProjectSettings.get_setting("display/window/size/height"))

var clusterContainer = {}
var discoveredSystems = []

var clusterLength = 6

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
	print("planets: " + str(planetNum))
	print("systems: " + str(systemNum))
			
func resetSystem():
	planetNum = 0
	systemNum = 0
	clusterContainer.clear()
	for i in range(-clusterLength,clusterLength + 1):
		for j in range(-clusterLength,clusterLength + 1):
			addCluster(Vector2(i,j))
