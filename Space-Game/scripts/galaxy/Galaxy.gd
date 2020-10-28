extends Node

var cellSize = 32 			# 32 pixels per cell
var clusterSize = 32 		# 32 cells in a cluster
var systemChance = 0.05 	# Chance of system occuring

var startSystem = Vector2(clusterSize/2,clusterSize/2)

enum STARTYPE {	O,	B,	A,	F,	G,	K,	M }

var starColour = {
	STARTYPE.O : {
		"colour" : Color(0.55,0.55,1,1),
		"sizeRange" : [6.6,6.6],
		"chance" : [0.99,1.0]
	},
	STARTYPE.B : {
		"colour" : Color(0.6,0.71,1,1),
		"sizeRange" : [1.8,4.0],
		"chance" : [0.97,0.99]
	},
	STARTYPE.A : {
		"colour" : Color(1,1,1,1),
		"sizeRange" : [1.4,1.8],
		"chance" : [0.93,0.97]
	},
	STARTYPE.F : {
		"colour" : Color(1,1,1,1),
		"sizeRange" : [1.15,1.4],
		"chance" : [0.85,0.93]
	},
	STARTYPE.G : {
		"colour" : Color(1,0.96,0.7,1),
		"sizeRange" : [0.96,1.15],
		"chance" : [0.7,0.85]
	},
	STARTYPE.K : {
		"colour" : Color(1,0.74,0.55,1),
		"sizeRange" : [0.7,0.96],
		"chance" : [0.5,0.7]
	},
	STARTYPE.M : {
		"colour" : Color(1,0.56,0.53,1),
		"sizeRange" : [0.5,0.7],
		"chance" : [0.0,0.5]
	},
}

enum PLANETTYPE {
	earthLike,
	waterWorld,
	rocky
}

var planetType = {
	PLANETTYPE.earthLike : {
		"fullName" : "Earthlike World",
		"colour" : [Color(0.33,0.45,0.53,1),Color(0.88,0.91,0.67,1),Color(0.58,0.88,0.51,1)],
		"thresholds" : [0.45,0.50,0.55],
		"radius" : [0.8, 1.5],
		"octaves" : [5, 9],
		"period" : [50.0,160.0],
		"persistence" : [0.4,1.0],
		"lacunarity" : [2.5,3.5],
		"hasAtmosphere" : true
	},
	PLANETTYPE.waterWorld : {
		"fullName" : "Water World",
		"colour" : [Color(0.33,0.45,0.53,1),Color(0.88,0.91,0.67,1),Color(0.58,0.88,0.51,1)],
		"thresholds" :[0.7,0.8,0.9],
		"radius" : [1.0, 1.2],
		"octaves" : [4, 9],
		"period" : [0.1,160.0],
		"persistence" : [0.3,0.7],
		"lacunarity" : [1.5,2.5],
		"hasAtmosphere" : true
	},
	PLANETTYPE.rocky : {
		"fullName" : "Rocky World",
		"colour" : [Color(0.69,0.69,0.69,1),Color(0.58,0.58,0.58,1),Color(0.34,0.34,0.34,1)],
		"thresholds" : [0.45,0.5,0.55],
		"radius" : [0.4, 0.8],
		"octaves" : [8, 9],
		"period" : [120.0,160.0],
		"persistence" : [0.6,1.0],
		"lacunarity" : [3.0,4.0],
		"hasAtmosphere" : false
	}
}

# Cluster of Stars [Acts as Chunks]
class Cluster:
	var id : Vector2		# Location Placeholder
	var position : Vector2	# Position of the Chunk
	var clusterName			# Name of Cluster
	var systems = {}		# Systems Container
	var systemNum			# Number of Systems
	var systemNames = []	# System Name Container
	
	# Takes optional systems, location, and name, if not, generates
	func _init(ID := Vector2.ZERO, Cluster_Name := "", System_Number = -1):
		var clusterSize = Galaxy.clusterSize		# Takes clustersize from the parent container
		var systemChance = Galaxy.systemChance		# Ditto
		id = ID										# Takes ID
		var position = id * Vector2(32,32) 			# Converts the cluster ID to world coordinates
		if Cluster_Name == "":						# If Cluster is empty, generate a cluster name, else, takes name
			_nameCluster()
		else:
			clusterName = Cluster_Name
		match System_Number:		# If predefined systems, pass, else, randomly calculate range
			-1:
				var avg = int(float(clusterSize)*float(clusterSize) * systemChance)
				Global.randomizeRNG()
				systemNum = Global.rng.randi_range(avg - 15,avg + 15)
			_:
				systemNum = System_Number
		for i in systemNum:
			var _name = _findName()
			_addSystem(i, _name)
	
	func _addSystem(_i : int, sysName := ""):
		Global.randomizeRNG()
		Global.systemNum += 1
		if id == Vector2.ZERO and _i == 0:
			systems[Galaxy.startSystem] = SolarSystem.new(sysName)
			#_nameSystem(tVec)
		else:
			var _t = false
			var x
			var y
			while _t == false:
				x = Global.rng.randi_range(0,Galaxy.clusterSize - 1)
				y = Global.rng.randi_range(0,Galaxy.clusterSize - 1)
				if !systems.has(Vector2(x,y)):
					systems[Vector2(x,y)] = SolarSystem.new(sysName)
					_t = true
	
	func _findName():
		var _t = false
		while !_t:
			var _sys = NameGenerator.randomSystem(clusterName)
			if !_sys in systemNames:
				systemNames.append(_sys)
				return(_sys)

	func _nameCluster():
		clusterName = NameGenerator.randomCluster()
		
	func _toJSON():
		var cJ = {
			"id" : self.id,
			"position" : self.position,
			"clusterName" : self.clusterName,
			"systems" : {},
			"systemNum" : self.systemNum,
			"systemNames" : self.systemNames
		}
		for c in systems:
			var cJSON = systems[c]._toJSON()
			cJ["systems"][c] = cJSON
		return cJ			

# Solar System Class [Rests Within Chunks]
class SolarSystem:
	
	var name							# Name of the system
	var planets = []					# Planet storage
	var starSize : float				# Size of the star
	var starType : int					# STARTYPE enum of the star colour 
	var planetNum: int					# Number of planets...
	var size setget ,size_get			# Allows for code to reference this
	var hasData = false					# Whether the player has data (visited, been there, etc.)
	
	# Randomization and addition of planets	
	func add_new_planet(_localID):
		
		Global.randomizeRNG()						# Randomizes the RNG
		var planetNum = 0							# Obtains the total amount of planets
		var _pType	 								# Defines a variable to hold the PlanetType
		var _name = str(self.name, " ", _localID)	#
		
		# Randomize the planet type
		var typeChance = Global.rng.randf_range(0.0,1.0)
		if typeChance < 0.1:
			_pType = PLANETTYPE.earthLike
		elif typeChance < 0.3:
			_pType = PLANETTYPE.waterWorld
		else:
			_pType = PLANETTYPE.rocky
		
		# Get ranges from dictionary
		var _planet = Galaxy.planetType[_pType]
		var _r = _planet["radius"]
		var _c = _planet["colour"]
		var _cT = _planet["thresholds"]
		var _o = _planet["octaves"]
		var _pd = _planet["period"]
		var _pe = _planet["persistence"]
		var _l = _planet["lacunarity"]
		
		# Create dictionary to pass to planetGen
		var planetData = {
			"planetType" : _pType,
			"name" : _name,
			"id" : planetNum,
			"localID" : _localID,
			"colours" : _c,
			"colourThresholds" : _cT,
			"hasAtmosphere" : _planet["hasAtmosphere"],
			"rotation" : Global.rng.randf_range(-0.2,0.2),
			"radius" : Global.rng.randf_range(_r[0],_r[1]),
			"seed" : Global.rng.randi_range(1,100),
			"octaves" : Global.rng.randi_range(_o[0],_o[1]),
			"period" : Global.rng.randf_range(_pd[0],_pd[1]),
			"persistence" : Global.rng.randf_range(_pe[0],_pe[1]),
			"lacunarity" : Global.rng.randf_range(_l[0],_l[1])
		}
		
		var p = Planet.new(planetData)		# Constructs new planet using data
		planets.append(p)					# Appends the planet to the planet list
		Global.planetNum += 1				# Adds to the global planet number

	# Initializes the System
	func _init(systemName := "", _planetNum := -1, _name := false):
		Global.randomizeRNG()
		name = systemName
		if _planetNum == -1:
			planetNum = Global.rng.randi_range(1,8)
		else:
			planetNum = _planetNum
		if _name:
			name = NameGenerator.randomSystem()
		
		var _sT = Global.rng.randf_range(0.0,1.0)
		for _star in Galaxy.starColour:
			var _r = Galaxy.starColour[_star]["chance"]
			if _sT <= _r[1] and _sT >= _r[0]:
				starType = _star
		
		var sRange = Galaxy.starColour[starType]["sizeRange"]
		starSize = Global.rng.randf_range(sRange[0],sRange[1])
		
		for i in planetNum:
			add_new_planet(i)
		
	func size_get():
		return planets.size()
		
	func _toJSON():
		var sJSON = {
			"name" : self.name,
			"planets" : {},
			"planetNum" : self.planetNum,
			"hasData" : self.hasData
		}
		for i in planets.size():
			var pJ = planets[i]._convertToJSON()
			sJSON["planets"][i] = pJ
		return sJSON
		
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
	var settlement : bool

	#storage for noise parameters
	var nSeed
	var octaves
	var period
	var persistence
	var lacunarity
	var radius

	# Storage for colour
	var colour1 = Color(0.33,0.45,0.53,1)
	var colour2 = Color(0.88,0.91,0.67,1)
	var colour3 = Color(0.58,0.88,0.51,1)

	# Colour Thresholds
	var c1t = 0.428
	var c2t = 0.516
	var c3t = 0.634

	func _init(planetDictionary):
		var _p = planetDictionary
		id = _p["id"]
		locID = _p["localID"]
		name = _p["name"]
		planetType = _p["planetType"]
		hasAtmosphere = _p["hasAtmosphere"]
		radius = _p["radius"]
		rotation = _p["rotation"]
		colour1 = _p["colours"][0]
		colour2 = _p["colours"][1]
		colour3 = _p["colours"][2]
		c1t = _p["colourThresholds"][0]
		c2t = _p["colourThresholds"][1]
		c3t = _p["colourThresholds"][2]
		nSeed = _p["seed"]
		octaves = _p["octaves"]
		period = _p["period"]
		persistence = _p["persistence"]
		lacunarity = _p["lacunarity"]

	func _convertToJSON():
		var pJSON = {
			"name" : self.name,
			"id" : self.id,
			"locID" : self.locID,
			"discovered" : self.discovered,
			"planetType" : self.planetType,
			"hasAtmosphere" : self.hasAtmosphere,
			"rotation" : self.rotation,
			"settlement" : self.settlement,
			"nSeed" : self.nSeed,
			"octaves" : self.octaves,
			"period" : self.period,
			"persistence" : self.persistence,
			"lacunarity" : self.lacunarity,
			"radius" : self.radius,
			"colour1" : self.colour1,
			"colour2" : self.colour2,
			"colour3" : self.colour3,
			"c1t" : self.c1t,
			"c2t" : self.c2t,
			"c3t" : self.c3t,
		}
		return pJSON
