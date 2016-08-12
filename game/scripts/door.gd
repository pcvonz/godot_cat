
extends MeshInstance

# member variables here, example:
# var a=2
# var b="textvar"
signal Door 
var open = false
func open_door():
	if open == false:
		print("playing")
		get_parent().get_node("AnimationPlayer").play("default")
		open = true
	else: 
		print("back")
		get_parent().get_node("AnimationPlayer").play_backwards("default")
		open = false
func _ready():
	connect("Door", self, "open_door")
	get_parent().get_parent().get_node("Observer").connect("Door", self, "open_door")


