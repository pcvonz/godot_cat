
extends Spatial

# member variables here, example:
# var a=2
# var b="textvar"

export var boids = 0
signal Door(node)
signal tty(node)
var open = false
var anim

func _ready():
	for i in range(0, boids):
		var temp = get_node("cat").duplicate()
		add_child(temp)
	var anim = get_node("Spatial 2/AnimationPlayer")
	connect("Door", self, "toggle_anim")
	get_node("Observer").connect("Door", self, "toggle_anim")
	connect("tty", self, "toggle_anim")
	get_node("Observer").connect("tty", self, "toggle_anim")

func toggle_anim(node):
	anim = node.get_parent().get_node("AnimationPlayer")
	if(anim.get_current_animation_pos() == 0):
		anim.play("default")
	else:
		anim.play_backwards()
