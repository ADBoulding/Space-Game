extends KinematicBody2D

var anim
var player
var cam

func _ready():
	var thisObj = self
	anim = self.get_node("AnimationPlayer")
	player = get_parent().get_node("Player")
	cam = get_node("Camera2D")
	anim.connect("animation_finished", thisObj, "changeCam")
	anim.play("Landing")

func _on_AnimationPlayer_animation_finished(anim_name, extra_arg_0):
	print("The script worked")
	player.set("visible", true)
	player.get_node("Camera2D").current = true
	cam.current = false
