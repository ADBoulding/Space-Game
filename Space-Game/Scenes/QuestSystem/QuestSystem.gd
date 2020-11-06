"""
Quest system script for starting and managing quests.
"""
extends Node

onready var title : Label = $CanvasLayer/Quest_Panel/Label
onready var questPanel : ColorRect = $CanvasLayer/Quest_Panel

enum QUESTTYPE {
	TRAVEL,
	EXPLORE,
	TRADE
}

var completed_quests = []

var current_quests = {}

var Quests = {
	"Test" : {
		"title" : "Test Quest",
		"description" : "The first quest, definitely a test quest.",
		"type" : QUESTTYPE.TRAVEL,
		"levels" : 1,
		"destination" : Vector2.ZERO
	}
}

func initialize(systemMap):
	systemMap.connect("ArrivedAtSystem", self, "_on_Arrival")
	#questPanel.show()
	title.text = Quests["Test"]["title"]
	pass

func testStartQuest():
	var systemLocation

func start(quest_name : String):
	if !quest_name in completed_quests and !quest_name in current_quests:
		current_quests[quest_name] = {"progress" : 0}
		

func _on_Quest_completed(quest):
	if !quest in completed_quests:
		completed_quests.append(quest)
		print("Quest has been completed : ",quest)
	
func _on_Arrival(currentSystem):
	print("OMG WE'VE arrived!")
	for quest in current_quests:
		if Quests[quest]["type"] == QUESTTYPE.TRAVEL:
			if Quests[quest]["destination"] == currentSystem:
				print("\nYES IT WORKED!!!!!!\n")
				questPanel.show()
				$CanvasLayer/Quest_Panel/Start.hide()
				$CanvasLayer/Quest_Panel/End.show()

func set_dest(dest : Vector2) -> void:
	Quests["Test"]["destination"] = dest

class QuestContainer:
	var quests = []
	func get_quests():
		return quests


func _on_Start_pressed():
	start("Test")
	questPanel.hide()


func _on_End_pressed():
	_on_Quest_completed("Test")
	questPanel.hide()
