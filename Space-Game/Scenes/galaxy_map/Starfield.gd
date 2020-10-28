extends TextureRect

class_name BSky

export var scroll_scale = 0.7

func resize(size):
	rect_size = size
	material.set_shader_param("viewport_size", size)


func set_offset(offset):
	material.set_shader_param("offset", offset * scroll_scale)
