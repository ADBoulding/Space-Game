extends Node

var rng = RandomNumberGenerator.new()
var planetNum = 0
var systemNum = 0

var systemContainer = []

func randomizeRNG():
	rng.randomize()

func addSystem(_num :=1):
	for n in range(_num):
		var currentSystem = Global.systemNum
		var system = SolarSystem.new(currentSystem, -1)
		systemContainer.append(system)
		Global.systemNum += 1

func init_system():
	addSystem(1)
	print("planets: " + str(planetNum))
	print("systems: " + str(systemNum))
			
func _ready():
	init_system()


### CLASSES ###
class SolarSystem:
	# Store planets and size
	var id
	var planets = []
	var planetNum: int
	var size setget ,size_get
		
	func add_new_planet(_localID):
		Global.randomizeRNG()
		var planetNum = Global.planetNum
		var radius = Global.rng.randf_range(0.5,5.0)
		var nSeed = Global.rng.randi_range(1,100)
		var octaves = Global.rng.randi_range(5,9)
		var period = Global.rng.randf_range(0.1,160.0)
		var persistence = Global.rng.randf_range(0.3,0.7)
		var lacunarity = Global.rng.randf_range(1.5,2.5)
		
		var p = Planet.new(planetNum,_localID,radius,nSeed,octaves,period,persistence,lacunarity)
		planets.append(p)
		Global.planetNum += 1

	func _init(_id := -1, _planetNum := -1):
		Global.randomizeRNG()
		if _id == -1:
			id = Global.systemNum
		else:	
			id = _id
			
		if _planetNum == -1:
			planetNum = Global.rng.randi_range(1,8)
		else:
			planetNum = _planetNum
		for i in planetNum:
			add_new_planet(i)
		
	func size_get():
		return planets.size()
		
	class Planet:
		# Storage for id
		var name = ""
		var id = 0
		var locID = 0
		
		# flag for discovered planet
		var discovered = false

		#storage for noise parameters
		var nSeed
		var octaves
		var period
		var persistence
		var lacunarity
		var radius

		#Storage for Noise
		#var noise: OpenSimplexNoise

		# Storage for colour
		var colour1 = Color(0.33,0.45,0.53,1)
		var colour2 = Color(0.88,0.91,0.67,1)
		var colour3 = Color(0.58,0.88,0.51,1)

		# Colour Thresholds
		var c1t = 0.428
		var c2t = 0.516
		var c3t = 0.634

		func _init(_id := -1, _localID := -1, _radius := 1.0, _seed := 1, _octaves := 5, _period := 64.0, _persistence := 0.5, _lacunarity := 2.0):
			if _id == -1:
				id = Global.planetNum
			else:
				id = _id
			locID = _localID
			radius = _radius
			nSeed = _seed
			octaves = _octaves
			period = _period
			persistence = _persistence
			lacunarity = _lacunarity
