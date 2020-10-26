extends Control

var system : Galaxy.SolarSystem
onready var title : Label = $TextureRect/Title
onready var planetType : Label = $TextureRect/Planet_Type
var pID : int

func _ready():
	self.hide()

func _changePlanetInfo(ID: int):
	var planet : Galaxy.Planet = system.planets[ID]
	var pID = ID
	var _title
	if planet.name == "":
		_title = "TEMPORARY NAME"
	else:
		_title = planet.name
	var _type = Galaxy.planetType[planet.planetType]["fullName"]
	

func _on_System_finishedGen():
	system = get_parent().system
	


func _on_LineEdit2_text_entered(new_text):
	get_parent().system.planets[pID].name = new_text
