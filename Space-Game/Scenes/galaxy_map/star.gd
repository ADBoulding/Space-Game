extends Node2D

signal clickedOn

onready var label : Label = $Label

var ID : Vector2
var star : Galaxy.SolarSystem

func setID(id : Vector2, cluster : Galaxy.Cluster):
	ID = id
	star = cluster.systems[ID]

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == true:
			print("\tClicked On : ",ID," / Global Position : ",global_position)
			emit_signal("clickedOn")


func _on_Area2D_mouse_entered():
	label.text = star.name
	label.show()
	pass # Replace with function body.


func _on_Area2D_mouse_exited():
	label.hide()
	pass # Replace with function body.
