extends Camera2D

signal CanUpdate

var sky : BSky
export var speed = 20.0
export var mSpeed = 10.0
export var zoomAmount = [0.5,1,1.5]
var _zoom_level = 0
export (float, 0.0, 5.0) var buff = 1.0 
var limits 
var sky_pos : float

var firstTime = true

var zooming
var moving
var focused

var destination : Vector2

onready var tPanel = get_parent().get_node("tPaneSlave/TPanel")

# Called when the node enters the scene tree for the first time.
func _ready():
	sky = get_parent().get_node("CanvasLayer/ParallaxBackground/Sky")
	sky.resize(get_viewport_rect().size)
	_zoom_level = 1
	zooming = true
	focused = false
	moving = false

func _moveToLocation(dest : Vector2):
	destination = dest
	moving = true
	focused = true

func _unFocus():
	focused = false

func _process(delta):
	var vecs
	if moving:
		if buffer(position, destination, buff):
			print("howdydoda")
			moving = false
			if focused:
				_unFocus()
			return
		vecs = Vector2(lerp(position.x,destination.x,mSpeed * delta),lerp(position.y,destination.y,mSpeed * delta))
		position = correctVector(vecs, limits)
	
	if zooming:
		var _dzoom = zoomAmount[_zoom_level]
		if buffer(zoom, Vector2(_dzoom,_dzoom), 0.05):
			zooming = false
			if firstTime:
				firstTime = false
				emit_signal("CanUpdate")
			return
		var _z = Vector2(lerp(zoom.x,_dzoom, delta * 2), lerp(zoom.y,_dzoom, delta * 2))
		zoom = _z
	
	sky.set_offset(position)
	
	if focused:
		return
			
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	vecs = Vector2(lerp(position.x, position.x + int(input_vector.x) * speed, speed * delta),lerp(position.y, position.y + int(input_vector.y) * speed, speed * delta))
	if input_vector != Vector2.ZERO:
		if checkLimits(vecs, limits):
			position = correctVector(vecs, limits)
	

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			#zoom in
			if event.button_index == BUTTON_WHEEL_UP:
				upZoom(Vector2(-0.1,-0.1))
			if event.button_index == BUTTON_WHEEL_DOWN:
				upZoom(Vector2(0.1,0.1))
			 
func upZoom(dest : Vector2):
	if zoom + dest > Vector2(3,3) || zoom + dest < Vector2(0.5,0.5) || zooming:
		return
	else:
		zoom += dest

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

func buffer(at : Vector2, dest : Vector2, buffer: float):
	if dest.x-at.x < buffer and dest.x-at.x > -buffer:
		if dest.y-at.y < buffer and dest.y-at.y > -buffer:
			return true
	return false

func _set_limits(cluster : Vector2):
	var clusterAmount = Global.clusterLength * 2 + 1
	var rect = Vector2(clusterAmount*Galaxy.cellSize*Galaxy.clusterSize,clusterAmount*Galaxy.cellSize*Galaxy.clusterSize)
	var _offset = rect / 2
	var camOffset = Vector2(Global.windowSize.x,Global.windowSize.y)
	var location = cluster * Galaxy.cellSize * Galaxy.clusterSize
	
	print(rect,_offset,camOffset,location)
	
	limits = Rect2(location-_offset+camOffset/2,rect-camOffset)
	print(limits.position,limits.end)
