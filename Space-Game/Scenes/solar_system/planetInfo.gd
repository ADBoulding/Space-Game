extends Control

var system : Galaxy.SolarSystem
onready var title : Label = $TextureRect/Title
onready var planetType : Label = $TextureRect/Planet_Type

func _ready():
	self.hide()

func _changePlanetInfo(ID: int):
	var planet : Galaxy.Planet = system.planets[ID]
	var _title
	if planet.name == "":
		_title = "TEMPORARY NAME"
	else:
		_title = planet.name
	var _type = Galaxy.planetType[planet.planetType]["fullName"]
	title.text = _title
	planetType.text = _type

func _on_System_finishedGen():
	system = get_parent().system
	
