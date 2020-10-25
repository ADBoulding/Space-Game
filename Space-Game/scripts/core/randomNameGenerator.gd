extends Node

var letters = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","W","R","S","T","U","V","W","X","Y","Z"]
var numbers = ["1","2","3","4","5","6","7","8","9","0"]
var alphaNumero = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","W","R","S","T","U","V","W","X","Y","Z","1","2","3","4","5","6","7","8","9","0"]

func randomCluster():
	Global.randomizeRNG()
	var _name = ""
	for i in range(0,3):
		var j = Global.rng.randi_range(0,letters.size()-1)
		_name += letters[j]
	return(_name)

func randomSystem(cluster := ""):
	Global.randomizeRNG()
	var _name = ""
	if cluster == "":
		_name = randomCluster()
	else:
		_name = cluster
	_name += "-"
	for i in range(0,3):
		var j = Global.rng.randi_range(0,alphaNumero.size()-1)
		_name += alphaNumero[j]
	return(_name)
