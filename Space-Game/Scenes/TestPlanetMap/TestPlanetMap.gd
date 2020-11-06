extends Node2D

onready var tilemap : TileMap = $TileMap
onready var player : KinematicBody2D = $Player
var noise = OpenSimplexNoise.new()

var system = Galaxy.SolarSystem

func _ready():
	system = Galaxy.SolarSystem.new("testSys", 1)
	noise = system.planets[0].noise
	player.get_node("Camera2D").current = true
	player.get_node("Camera2D").zoom = Vector2(2.25,2.25)
	GenerateNoise(-100,-100,200,200)
	pass


func GenerateNoise(x_pos,y_pos,width,height):
	for x in range(width):
		for y in range(height):
			tilemap.set_cell(x+x_pos,y+y_pos,noise.get_noise_2d(x+x_pos,y+y_pos)*2+2)
