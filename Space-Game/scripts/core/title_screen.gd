extends Control

onready var newGame : Button = $Menu/Buttons/NewGameButton
export(PackedScene) var target_scene

# Called when the node enters the scene tree for the first time.
func _ready():
	newGame.connect("button_down", self, "_newGame")

func _newGame():
	print("GOING TO NEW GAME")
	#Global.init_system()
	var err = get_tree().change_scene_to(target_scene)	
