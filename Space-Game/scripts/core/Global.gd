extends Node

var rng = RandomNumberGenerator.new()
var planetNum = 0
var systemNum = 0

enum PLANETTYPE {
	earthLike,
	waterWorld,
	rocky
}

var planetReference = {
	"earthLike" : {
		"colour" : [Color(0.33,0.45,0.53,1),Color(0.88,0.91,0.67,1),Color(0.58,0.88,0.51,1)],
		"thresholds" : [0.428,0.516,0.634],
		"radius" : [0.8, 1.5],
		"octaves" : [5, 9],
		"period" : [120.0,160.0],
		"persistence" : [0.6,1.0],
		"lacunarity" : [1.5,2.5]
	},
	"waterWorld" : {
		"colour" : [Color(0.33,0.45,0.53,1),Color(0.88,0.91,0.67,1),Color(0.58,0.88,0.51,1)],
		"thresholds" :[0.7,0.8,0.9],
		"radius" : [1.0, 1.2],
		"octaves" : [4, 9],
		"period" : [0.1,160.0],
		"persistence" : [0.3,0.7],
		"lacunarity" : [1.5,2.5]
	},
	"rocky" : {
		"colour" : [Color(0.69,0.69,0.69,1),Color(0.58,0.58,0.58,1),Color(0.34,0.34,0.34,1)],
		"thresholds" : [0.45,0.5,0.55],
		"radius" : [0.4, 0.8],
		"octaves" : [8, 9],
		"period" : [120.0,160.0],
		"persistence" : [0.6,1.0],
		"lacunarity" : [3.0,4.0]
	}
}

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
	
	# Randomization and addition of planets	
	func add_new_planet(_localID):
		Global.randomizeRNG()
		var planetNum = Global.planetNum
		
		var planetType
		
		# Randomize the planet type
		var typeChance = Global.rng.randf_range(0.0,1.0)
		if typeChance < 0.1:
			planetType = "earthLike"
		elif typeChance < 0.3:
			planetType = "waterWorld"
		else:
			planetType = "rocky"
		
		# Get ranges
		var _planet = Global.planetReference[planetType]
		var _r = _planet["radius"]
		var _c = _planet["colour"]
		var _cT = _planet["thresholds"]
		var _o = _planet["octaves"]
		var _pd = _planet["period"]
		var _pe = _planet["persistence"]
		var _l = _planet["lacunarity"]
		
		# Use RNG to determine the planet parameters
		var radius = Global.rng.randf_range(_r[0],_r[1])
		var nSeed = Global.rng.randi_range(1,100)
		var octaves = Global.rng.randi_range(_o[0],_o[1])
		var period = Global.rng.randf_range(_pd[0],_pd[1])
		var persistence = Global.rng.randf_range(_pe[0],_pe[1])
		var lacunarity = Global.rng.randf_range(_l[0],_l[1])
		
		var p = Planet.new(planetNum,_localID,radius,_c,_cT,nSeed,octaves,period,persistence,lacunarity)
		planets.append(p)
		print("generated a [" + planetType + "] world")
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

		# flag for planet type
		var planetType
		var hasAtmosphere
		var rotation

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

		func _init(_id := -1, _localID := -1, _radius := 1.0, _colours := [], _colourThresholds := [], _seed := 1, _octaves := 5, _period := 64.0, _persistence := 0.5, _lacunarity := 2.0):
			if _id == -1:
				id = Global.planetNum
			else:
				id = _id
			locID = _localID
			radius = _radius
			colour1 = _colours[0]
			colour2 = _colours[1]
			colour3 = _colours[2]
			c1t = _colourThresholds[0]
			c2t = _colourThresholds[1]
			c3t = _colourThresholds[2]
			nSeed = _seed
			octaves = _octaves
			period = _period
			persistence = _persistence
			lacunarity = _lacunarity
			
			rotation = Global.rng.randf_range(0.0,1.0)
