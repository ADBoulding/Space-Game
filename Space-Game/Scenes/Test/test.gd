extends Control

onready var label = $Label
var vec : Vector2 = Vector2.ZERO
var dict = {}


func _on_Button_pressed():
	Global.init_system()
	print("Generated")
	
func _on_LoadSystem_pressed():
	var file = File.new()
	if file.file_exists("res://debug/save/save.sav"):
		file.open("res://debug/save/save.sav", File.READ)
		var raw = parse_json(file.get_line())
		print(raw)
		if typeof(raw) == TYPE_DICTIONARY:
			print(raw)
		else:
			push_error("UNEXPECTED>>>")
	file.close()
	
func _on_SaveSystem_pressed():
	if Global.clusterContainer.size() == 0:
		print("THERES NOTHING TO SAVE!!")
		return
	var file = File.new()
	file.open("res://debug/save/save.json", File.WRITE)
	var _d = saveFile()
	_d = to_json(_d)
	file.store_line(_d)
	file.close()
	print("saved")

func testJSON():
	var _s = Global.clusterContainer[Vector2(0,0)].systems[Galaxy.startSystem]
	var clusterJSON = {}
	var _cP : Galaxy.Planet
	print(_s._toJSON())

func saveFile():
	var _d = Global.clusterContainer
	var clusterJSON = {}
	for c in _d:
		clusterJSON[c] = _d[c]._toJSON()
	return clusterJSON
	
func loadDefaultSystems():
	var filePath = "res://Files/defaultSystems.json"
	var file = File.new()
	if not file.file_exists(filePath):
		print("AWE SHIIIIIIT")
		return
	print("FILE EXISTS")
	file.open(filePath, file.READ)
	
	var text = file.get_as_text()
	var data = parse_json(text)
	file.close()
	
	for bit in data:
		print(bit)

func _on_default_Systems_pressed():
	var filePath = "res://Files/defaultSystems.json"
	var file = File.new()
	if not file.file_exists(filePath):
		print("AWE SHIIIIIIT")
		return
	print("FILE EXISTS")
	file.open(filePath, file.READ)
	
	var text = file.get_as_text()
	var data = JSON.parse(text).result
	file.close()
	
	var system = Galaxy.SolarSystem.new("",0,false)
	system._loadFromJSON(data["startingSystem"])	
	
	for _p in system.planets:
		print(_p.name)
