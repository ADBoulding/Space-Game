extends Spatial

export var SystemID : Vector2
var system: Galaxy.SolarSystem

signal finishedGen

onready var galaxyB : Button = $Control/Galaxy_Map
onready var prevButton : Button = $Control/Prev
onready var nextButton : Button = $Control/Next
onready var label : Label = $Control/Label
onready var cam : Camera = $Camera

var pNodes

var camLimits

# Called when the node enters the scene tree for the first time.
func _ready():
	galaxyB.connect("pressed", self, "_returnToGalaxy")
	SystemID = Global.currentSystem
	system = Global.currSys
	Global.clusterContainer[Global.currentCluster].systems[Global.currentSystem].hasData = true
	genPlanets()
	emit_signal("finishedGen")
		
func genPlanets():
	updateScene()
	pNodes = []
	for _p in system.planets:
		var planet = load("res://Scenes/Planet.tscn").instance()
		planet.translation.x = _p.locID * 5 + 15
		planet.mesh.radius = _p.radius
		planet.mesh.height = _p.radius * 2
		planet.get_node("Clouds").mesh.radius = _p.radius + _p.radius/50
		planet.get_node("Clouds").mesh.height = _p.radius * 2 + _p.radius/25
		planet.setID(SystemID, _p.locID, _p.id)
		var pName = "planet_" + str(SystemID) + "-" + str(_p.locID)
		print (pName)
		planet.name = pName
		add_child(planet)
		var _planet = get_node(pName)
		_planet.connect("clickedOn", cam, "_focus", [_p.locID])
		pNodes.append(_planet)
	print("NODELENGTH : " + str(pNodes.size()))

func _returnToGalaxy():
	var target_scene = load("res://Scenes/galaxy_map/Galaxy_Map.tscn")
	var err = get_tree().change_scene_to(target_scene)	
	pass
	
func updateScene():
	label.text = "System : " + str(SystemID.x) + "/" + str(SystemID.y) 
