extends MeshInstance

export var SystemID: int
export var ID: int
export var LocalID: int

export var colour1 = Color(0.33,0.45,0.53,1)
export var colour2 = Color(0.88,0.91,0.67,1)
export var colour3 = Color(0.58,0.88,0.51,1)

export var c1t = 0.428
export var c2t = 0.516
export var c3t = 0.634

var planet: Global.SolarSystem.Planet 

var nSeed = 1
var octaves = 1
var period = 64.0
var persistence = 0.5
var lacunarity = 2.0

export(NoiseTexture) var Albedo = NoiseTexture.new()

var noise := OpenSimplexNoise.new()

var mat

func _load_planet():
	if Global.systemContainer[SystemID].planets[LocalID] != null:
		print("everything is Kosher")
		planet = Global.systemContainer[SystemID].planets[LocalID]
		
		noise.seed = planet.nSeed
		noise.octaves = planet.octaves
		noise.period = planet.period
		noise.persistence = planet.persistence
		noise.lacunarity = planet.lacunarity
		
		_draw_planet()
		
	else:
		print("Uh Oh")
		
		
func _draw_planet():
	var image = noise.get_seamless_image(400)
	var image_texture = ImageTexture.new()
	image_texture.create_from_image(image)
	mat.set_shader_param("Base_Albedo",image_texture)

#Constructor for the script				
func setID(_sysID, _locID, _ID):
	SystemID = _sysID
	LocalID = _locID
	ID = _ID
	

# Called when the node enters the scene tree for the first time.
func _ready()->void:
	mat = self.get_surface_material(0)
	_load_planet()
	
		
	

