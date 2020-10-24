extends Control

var system : Global.SolarSystem
onready var title : Label = $TextureRect/Title
onready var planetType : Label = $TextureRect/Planet_Type

func _ready():
	self.hide()

func _changePlanetInfo(ID: int):
	var planet : Global.SolarSystem.Planet = system.planets[ID]
	var _title
	if planet.name == "":
		_title = "TEMPORARY NAME"
	var _type = Global.planetReference[planet.planetType]["fullName"]
	title.text = _title
	planetType.text = _type
	

func _on_System_finishedGen():
	system = get_parent().system
	
