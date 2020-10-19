extends Spatial

export var SystemID: int
var system: Global.SolarSystem

# Called when the node enters the scene tree for the first time.
func _ready():
	if Global.systemContainer.size() == 0:
		Global.init_system()
		SystemID = 0
	system = Global.systemContainer[SystemID]
	for _p in system.planets:
		var planet = load("res://Scenes/Planet.tscn").instance()
		planet.translation.x = _p.locID * 5 + 15
		planet.mesh.radius = _p.radius
		planet.mesh.height = _p.radius * 2
		planet.setID(SystemID, _p.locID, _p.id)
		add_child(planet)
	
	

func _init(_SystemID := 0):
	SystemID = _SystemID
