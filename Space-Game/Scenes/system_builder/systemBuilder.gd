extends Spatial

var system : Galaxy.SolarSystem

signal finishedGen

onready var cam : Camera = $Camera
onready var container : Node2D = $container
onready var report : ColorRect = $SystemReport

var camLimits

var planetResource = load("res://Scenes/Planet.tscn")
var planets = []

# Called when the node enters the scene tree for the first time.
func _ready():
	system = Galaxy.SolarSystem.new("",0,false)
	
	#genPlanets()
		
func genPlanets():
	for _p in system.planets:
		var planet = planetResource.instance()
		planet.translation.x = _p.locID * 5 + 15
		planet.mesh.radius = _p.radius
		planet.mesh.height = _p.radius * 2
		planet.get_node("Clouds").mesh.radius = _p.radius + _p.radius/50
		planet.get_node("Clouds").mesh.height = _p.radius * 2 + _p.radius/25
		planet.setID(_p)
		var pName = str("p_",_p.locID)
		planet.name = pName
		container.add_child(planet)
		var _planet = container.get_node(pName)
		_planet.connect("clickedOn", cam, "_focus", [_p.locID])

func addPlanet():
	var i = system.planets.size()
	system.add_new_planet(i)
	var _p = system.planets[i]
	var planet = planetResource.instance()
	planet.translation.x = _p.locID * 5 + 15
	planet.mesh.radius = _p.radius
	planet.mesh.height = _p.radius * 2
	planet.get_node("Clouds").mesh.radius = _p.radius + _p.radius/50
	planet.get_node("Clouds").mesh.height = _p.radius * 2 + _p.radius/25
	planet.setID(_p)
	var pName = str("p_",_p.locID)
	planet.name = pName
	container.add_child(planet)
	var _planet = container.get_node(pName)
	_planet.connect("clickedOn", cam, "_focus", [i])
	emit_signal("finishedGen")
	
func updatePanel():
	var _name = report.get_node("SystemName")
	var _num = report.get_node("PlanetNum")
	
	_name.text = str("System : ",system.name)
	_num.text = str("Planets : ",system.planetNum)

func _on_newPlanet_pressed():
	addPlanet()
	updatePanel()


func _on_LineEdit_text_entered(new_text):
	system.name = new_text
	updatePanel()


func _on_LineEdit_focus_entered():
	print("FOCUSED")
	cam._canMove(false)

func _on_LineEdit_focus_exited():
	cam._canMove(true)


func _on_LineEdit2_focus_entered():
	cam._canMove(false)


func _on_LineEdit2_focus_exited():
	cam._canMove(true)
