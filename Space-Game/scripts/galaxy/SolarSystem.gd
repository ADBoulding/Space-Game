extends Spatial

var system : Galaxy.SolarSystem
var systemID : Vector2
var clusterID : Vector2

signal finishedGen

onready var cam : Camera = $Camera
onready var container : Node2D = $container

var camLimits

var planetResource = load("res://Scenes/Planet_Gen/Planet.tscn")
var planets = []

var isManual = false

func _ready():
	initialize()

func initialize(_system : Galaxy.SolarSystem = null):
	match _system:
		null:
			match Global.clusterContainer.size():
				0:
					system = Galaxy.SolarSystem.new("",-1,true)
					systemID = Vector2.ZERO
					clusterID = Vector2.ZERO
					isManual = true
				_:
					systemID = Global.currentSystemID
					clusterID = Global.currentClusterID
					system = Global.clusterContainer[clusterID].systems[systemID]
		_:
			system = _system
			systemID = Vector2.ZERO
			clusterID = Vector2.ZERO
			isManual = true
	
	genPlanets()

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
	emit_signal("finishedGen")

func _on_Galaxy_Map_pressed():
	if isManual:
		return
	var target_scene = load("res://Scenes/galaxy_map/Galaxy_Map.tscn")
	var err = get_tree().change_scene_to(target_scene)	
	
