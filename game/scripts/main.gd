
extends Spatial

# member variables here, example:
# var a=2
# var b="textvar"

export var boids = 0
var open = false
var obs

func _ready():
	for i in range(0, boids):
		var temp = get_node("cat").duplicate()
		add_child(temp)
	obs = get_node("Observer")
	get_node("entry_door/door/col/col").connect("input_event", self, "toggle_anim", [get_node("entry_door")])
	get_node("closet_door 2/door/col/col").connect("input_event", self, "toggle_anim", [get_node("closet_door 2")])
	get_node("valentine/tty/col").connect("input_event", self, "toggle_anim", [get_node("valentine")])
	get_node("small lamp/lamp/col").connect("input_event", self, "toggle_light", [get_node("small lamp")])
	get_node("tall_lamp/lamp/col").connect("input_event", self, "toggle_light", [get_node("tall_lamp")])
	get_node("small lamp1/lamp/col").connect("input_event", self, "toggle_light", [get_node("small lamp1")])
	
func toggle_anim(camera, event, click_pos, click_normal, shape_idx, object):
	var anim = object.get_node("AnimationPlayer")
	var dist = object.get_translation()
	dist = dist.distance_to(obs.get_translation())
	var anim = object.get_node("AnimationPlayer")
	if(event.is_action_pressed("interact") and dist < 4):
		if(anim.get_current_animation_pos() == 0):
			anim.play("default")
		else:
			anim.play_backwards()

func toggle_light( camera, event, click_pos, click_normal, shape_idx, object):
	var light = object.get_node("light")
	var dist = object.get_translation()
	dist = dist.distance_to(obs.get_translation())
	if(event.is_action_pressed("interact") and dist < 4):
		print(event)
		print(shape_idx)
		if(light.is_enabled()):
			light.set_enabled(false)
		else:
			light.set_enabled(true)