extends Camera2D

export var speed = 20.0
export var mSpeed = 10.0
export var zoomAmount = 5
export (float, 0.0, 5.0) var buff = 1.0 
var limits 

var moving
var focused

var destination : Vector2

onready var tPanel = get_parent().get_node("CanvasLayer/TPanel")

# Called when the node enters the scene tree for the first time.
func _ready():
	focused = false
	moving = false

func _moveToLocation(dest : Vector2):
	destination = dest
	moving = true
	focused = true

func _unFocus():
	focused = false
	tPanel.hide()

func _process(delta):
	var vecs
	if moving:
		if buffer(position, destination):
			print("howdydoda")
			moving = false
			tPanel.rect_position = Vector2(330,190)
			tPanel.show()
			return
		vecs = Vector2(lerp(position.x,destination.x,mSpeed * delta),lerp(position.y,destination.y,mSpeed * delta))
		position = correctVector(vecs, limits)
	
	if focused:
		return
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	vecs = Vector2(lerp(position.x, position.x + int(input_vector.x) * speed, speed * delta),lerp(position.y, position.y + int(input_vector.y) * speed, speed * delta))
	if input_vector != Vector2.ZERO:
		if checkLimits(vecs, limits):
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

func buffer(at : Vector2, dest : Vector2):
	if dest.x-at.x < buff and dest.x-at.x > -buff:
		if dest.y-at.y < buff and dest.y-at.y > -buff:
			return true
	return false

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
