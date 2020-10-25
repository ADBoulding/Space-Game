extends Control

onready var label = $Label
var vec : Vector2 = Vector2.ZERO

func _on_Button_pressed():
	Global.init_system()
	for cluster in Global.clusterContainer:
		print (cluster)
	
