extends KinematicBody2D

# Based on Heartbeasts action rpg

var velocity = Vector2.ZERO

var speed = 4.0

func _physics_process(delta):
	match Input.get_action_strength("ui_shift") >= 1:
		true:
			speed = 8.0
		false:
			speed = 4.0
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		velocity = input_vector * speed
	else:
		velocity = Vector2.ZERO
		 
	move_and_collide(velocity)
