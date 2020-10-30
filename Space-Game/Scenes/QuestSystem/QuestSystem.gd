"""
Quest system script for starting and managing quests.
"""
extends Node

onready var available_quests = $Available
onready var active_quests = $Active
onready var completed_quests = $Completed
onready var delivered_quests = $Delivered

func initialize()

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
