extends Camera2D

export var speed = 20.0
var limits 

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	var vecs = Vector2(lerp(position.x, position.x + int(input_vector.x) * speed, speed * delta),lerp(position.y, position.y + int(input_vector.y) * speed, speed * delta))
	if input_vector != Vector2.ZERO:
		if checkLimits(vecs, limits):
			position = vecs
		else:
			position = correctVector(vecs, limits)

func checkLimits(vector, rect):
	if vector.x <= rect.end.x and vector.x >= rect.position.x:
		if vector.y <= rect.end.y and vector.y >= rect.position.y:
			return true
	return false

func correctVector(vector:Vector2, rect):
	var _nVec = vector
	if vector.x < rect.position.x:
		_nVec.x = rect.position.x
	elif vector.x > rect.end.x:
		_nVec.x = rect.end.x
	
	if vector.y < rect.position.y:
		_nVec.y = rect.position.y
	elif vector.y > rect.end.y:
		_nVec.y = rect.end.y
	return _nVec

func _set_limits():
	limit_left = 0
	limit_right = 0
	limit_bottom = 0
	limit_top = 0	
		
	var tilemap = get_parent().get_node("TileMap")
	if tilemap is TileMap:
		var limit = tilemap.get_used_rect()
		print(limit)
		position.x = limit.end.x * tilemap.cell_size.x / 2
		position.y = limit.end.y * tilemap.cell_size.y / 2
		limit_right = max(limit.end.x * tilemap.cell_size.x, limit_right)
		limit_bottom = max(limit.end.y * tilemap.cell_size.y, limit_bottom)
	limits = Rect2(Vector2(limit_left + Global.windowSize.x/2, limit_top + Global.windowSize.y/2),Vector2(limit_right - Global.windowSize.x, limit_bottom - Global.windowSize.y))
	print(Vector2(limit_left,limit_top),Vector2(limit_right,limit_bottom))
