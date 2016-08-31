
extends Spatial

# member variables here, example:
# var a=2
# var b="textvar"

export var boids = 0
signal door(node)
signal tty(node)
signal lamp(node)
var open = false
var anim

func _ready():
	for i in range(0, boids):
		var temp = get_node("cat").duplicate()
		add_child(temp)
	var anim
	connect("door", self, "toggle_anim")
	get_node("Observer").connect("door", self, "toggle_anim")
	connect("tty", self, "toggle_anim")
	get_node("Observer").connect("tty", self, "toggle_anim")
	connect("lamp", self, "toggle_light")
	get_node("Observer").connect("lamp", self, "toggle_light")
	
func toggle_anim(node):
	anim = node.get_parent().get_node("AnimationPlayer")
	if(anim.get_current_animation_pos() == 0):
		anim.play("default")
	else:
		anim.play_backwards()

func toggle_light(node):
	var light = node.get_node("../light")
	if(light.is_enabled()):
		light.set_enabled(false)
	else:
		light.set_enabled(true)