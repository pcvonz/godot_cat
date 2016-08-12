
extends Spatial

# member variables here, example:
# var a=2
# var b="textvar"

export var boids = 0
signal Door
var open = false
var anim

func _ready():
	for i in range(0, boids):
		var temp = get_node("cat").duplicate()
		add_child(temp)
	var anim = get_node("Spatial 2/AnimationPlayer")
	connect("Door", self, "open_door")
	get_node("Observer").connect("Door", self, "open_door")

func open_door(node):
	print("yay")
	if open == false:
		node.get_parent().get_node("AnimationPlayer").play("door")
		open = true
	else: 
		print("back")
		node.get_parent().get_node("AnimationPlayer").play_backwards("door")
		open = false
