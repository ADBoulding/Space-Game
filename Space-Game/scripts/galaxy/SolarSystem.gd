extends Spatial

export var SystemID: int
var system: Global.SolarSystem

var newGbutton : Button
var prevButton : Button
var nextButton : Button
var label : Label

var pNodes

# Called when the node enters the scene tree for the first time.
func _ready():
	newGbutton = $Control/New_System
	prevButton = $Control/Prev
	nextButton = $Control/Next
	label = $Control/Label
	newGbutton.connect("pressed", self, "newSystem")
	prevButton.connect("pressed", self, "prevSystem")
	nextButton.connect("pressed", self, "nextSystem")
	if Global.systemContainer.size() == 0:
		Global.init_system()
		SystemID = 0
	genPlanets()
		

func _init(_SystemID := 0):
	SystemID = _SystemID
	pNodes = []

func genPlanets():
	system = Global.systemContainer[SystemID]
	updateScene()
	pNodes.clear()
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

func newSystem():
	Global.addSystem(1)
	SystemID = Global.systemNum - 1
	changeSystem()
	
func prevSystem():
	if !(SystemID - 1 < 0):
		SystemID -= 1
		changeSystem()
	print(str(SystemID) + "/" + str(Global.systemNum - 1))

func nextSystem():
	if !(SystemID +1 > Global.systemNum - 1):
		SystemID += 1
		changeSystem()
	print(str(SystemID) + "/" + str(Global.systemNum - 1))
		
func changeSystem():
	if (pNodes):
		for planet in pNodes:
			planet.queue_free()
	genPlanets()

func updateScene():
	label.text = "System : " + str(SystemID + 1) + "/" + str(Global.systemNum) 
