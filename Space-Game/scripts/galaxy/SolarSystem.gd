extends Spatial

export var SystemID : Vector2
var system: Global.SolarSystem

onready var galaxyB : Button = $Control/Galaxy_Map
onready var prevButton : Button = $Control/Prev
onready var nextButton : Button = $Control/Next
onready var label : Label = $Control/Label

var pNodes

# Called when the node enters the scene tree for the first time.
func _ready():
	galaxyB.connect("pressed", self, "_returnToGalaxy")
#	prevButton.connect("pressed", self, "prevSystem")
#	nextButton.connect("pressed", self, "nextSystem")
	SystemID = Global.currentSystem
	genPlanets()
		
func genPlanets():
	var _x = str(SystemID.x)
	var _y = str(SystemID.y)
	system = Global.systemDictionary[_x][_y]
	updateScene()
	pNodes = []
	for _p in system.planets:
		var planet = load("res://Scenes/Planet.tscn").instance()
		planet.translation.x = _p.locID * 5 + 15
		planet.mesh.radius = _p.radius
		planet.mesh.height = _p.radius * 2
		planet.setID(SystemID, _p.locID, _p.id)
		var pName = "planet_" + str(SystemID) + "-" + str(_p.locID)
		print (pName)
		planet.name = pName
		add_child(planet)
		pNodes.append(get_node(pName))
	print("NODELENGTH : " + str(pNodes.size()))

func _returnToGalaxy():
	var target_scene = load("res://Scenes/galaxy_map/Galaxy_Map.tscn")
	var err = get_tree().change_scene_to(target_scene)	
	pass
	
func updateScene():
	label.text = "System : " + str(SystemID.x) + "/" + str(SystemID.y) 
