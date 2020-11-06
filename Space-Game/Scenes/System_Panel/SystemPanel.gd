extends Control

onready var systemDisplay : Spatial = $ViewportContainer/Viewport/System
var systemCamera : Camera

var currentSystem : Galaxy.SolarSystem

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass
	
func updateTitle(id = -1):
	match id:
		-1:
			$ColorRect/Title.text = currentSystem.name
		_:
			$ColorRect/Title.text = currentSystem.planets[id].name
			$ColorRect/planetType.text = Galaxy.planetType[currentSystem.planets[id].planetType]["fullName"]

func _on_Viewport_ready():
	systemDisplay = $ViewportContainer/Viewport/System
	systemCamera = $ViewportContainer/Viewport/System/Camera
	systemCamera.connect("focusedOn", self, "updateTitle")
	systemCamera.connect("unFocused", self, "updateTitle")
	print("WORKED I THINK")
	systemDisplay.initialize()
	currentSystem = systemDisplay.system
	updateTitle()
	pass # Replace with function body.
