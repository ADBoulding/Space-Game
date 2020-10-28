extends Node2D

signal clickedOn

onready var label : Label = $Label

var ID : Vector2
var star : Galaxy.SolarSystem

#func _ready():
#	Global.randomizeRNG()
#	var size = star.starSize
#	var colour = Galaxy.starColour[star.starType]["colour"]
#	var mat = $Sprite.get_material()
#	$Sprite.scale = Vector2(size,size)
#	mat.set_shader_param("starColour", colour)	

func setID(id : Vector2, cluster : Galaxy.Cluster):
	ID = id
	star = cluster.systems[ID]
	var size = star.starSize * 2
	var colour = Galaxy.starColour[star.starType]["colour"]
	var mat = $Sprite.get_material()
	$Sprite.scale = Vector2(size,size)
	mat.set_shader_param("starColour", colour)

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == true:
			print("\nClicked On : ",ID," / Global Position : ",global_position)
			print("\tstarType : ",star.starType)
			print("\tstar size : ",star.starSize)
			print("\tRANGE : ",Galaxy.starColour[star.starType]["sizeRange"])
			emit_signal("clickedOn")


func _on_Area2D_mouse_entered():
	label.text = star.name
	label.show()
	pass # Replace with function body.


func _on_Area2D_mouse_exited():
	label.hide()
	pass # Replace with function body.
