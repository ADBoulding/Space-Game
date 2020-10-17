extends Control

var noise = OpenSimplexNoise.new()
var noise_texture = NoiseTexture.new()

func _ready():
	noise_texture.noise = noise
	$TextureRect.texture = noise_texture
	
	
#	var image = noise.get_seamless_image(640)
#	var updatedImage = ImageTexture.new().create_from_image(image)
#	self.texture = updatedImage
