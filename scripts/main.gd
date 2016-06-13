
extends Spatial

# member variables here, example:
# var a=2
# var b="textvar"

export var boids = 0


func _ready():
	for i in range(0, boids):
		var temp = get_node("cat1").duplicate()
		add_child(temp)


