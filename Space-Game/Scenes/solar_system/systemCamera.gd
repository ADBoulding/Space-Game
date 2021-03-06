extends Camera

signal focusedOn
signal unFocused

var normalPosition = Vector3(25.0,0.0,40.0)
var camPosition = []
var speed = 10
var zoom = [40, 20, 10]
var zoomLevel = 0
var focusedOn = -1

var totalPlanets

enum STATE {
	FOCUSED,
	UNFOCUSED
}

var cameraState 

func _ready():
	cameraState = STATE.UNFOCUSED
	zoomLevel = 0
	
func _getPlanets():
	var pNodes = get_parent().get_node("container").get_children()
	camPosition.clear()
	for node in pNodes:
		var _position = node.translation
		_position.z = node.mesh.radius + 2
		camPosition.append(_position)
		
func _input(event):
	if cameraState == STATE.UNFOCUSED:
		if event.is_action_pressed("ui_up"):
			if zoomLevel < 2:
				zoomLevel += 1
				match zoomLevel:
					0:
						translation.z = 40
					1:
						translation.z = 20
					2:
						translation.z = 10
			elif zoomLevel == 2:
				_focus(0)
		elif event.is_action_pressed("ui_down"):
			if zoomLevel > 0:
				zoomLevel -= 1
				match zoomLevel:
					0:
						translation.z = 40
					1:
						translation.z = 20
					2:
						translation.z = 10
	else:
		if event.is_action_pressed("ui_left"):
			if focusedOn > 0:
				focusedOn -= 1
				_focus(focusedOn)
		elif event.is_action_pressed("ui_right"):
			if focusedOn < totalPlanets - 1:
				focusedOn += 1
				_focus(focusedOn)
		elif event.is_action_pressed("ui_down"):
			_unFocus()

func _process(delta):
	if cameraState == STATE.UNFOCUSED:
		var input_vector = Vector3.ZERO
		input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		#input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		if input_vector != Vector3.ZERO:
			global_translate(input_vector * delta * speed)

func _moveToPosition(destination):
	translation = destination
	pass

func _focus(id):
	cameraState = STATE.FOCUSED
	_moveToPosition(camPosition[id])
	focusedOn = id
	emit_signal("focusedOn", focusedOn)
	
func _unFocus():
	focusedOn = -1
	cameraState = STATE.UNFOCUSED
	_moveToPosition(normalPosition)
	zoomLevel = 0
	emit_signal("unFocused")

func _on_System_finishedGen():
	_getPlanets()
	totalPlanets = get_parent().system.planetNum
