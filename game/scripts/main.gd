
extends Spatial

# member variables here, example:
# var a=2
# var b="textvar"

export var boids = 0
signal door(node)
signal tty(node)
signal lamp( camera, event, click_pos, click_normal, shape_idx, light)
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
	get_node("small lamp/lamp/col").connect("input_event", self, "toggle_light", [get_node("small lamp/light")])
	get_node("tall_lamp/lamp/col").connect("input_event", self, "toggle_light", [get_node("tall_lamp/light")])
	get_node("small lamp1/lamp/col").connect("input_event", self, "toggle_light", [get_node("small lamp1/light")])
	
func toggle_anim(node):
	anim = node.get_parent().get_node("AnimationPlayer")
	if(anim.get_current_animation_pos() == 0):
		anim.play("default")
	else:
		anim.play_backwards()

func toggle_light( camera, event, click_pos, click_normal, shape_idx, light):
	if(event.is_action_pressed("interact")):
		print(event)
		print(shape_idx)
		if(light.is_enabled()):
			light.set_enabled(false)
		else:
			light.set_enabled(true)