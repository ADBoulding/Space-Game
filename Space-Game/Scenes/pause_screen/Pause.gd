extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	set_visibility(false)

func _input(event):
	if event.is_action_pressed("ui_cancel"): # Escape by default
		set_visibility(!get_tree().paused) # if not pause then hide
		get_tree().paused = !get_tree().paused # toggle pause
			
func set_visibility(is_visible):
	for node in get_children():
		node.visible = is_visible

func _on_Continue_pressed():
	get_tree().paused = false
	set_visibility(false)

func _on_MainMenu_pressed():
	get_tree().paused = false
	var target_scene = load("res://Scenes/title_screen.tscn")
	var err = get_tree().change_scene_to(target_scene)	
