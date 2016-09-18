
extends Spatial

# member variables here, example:
# var a=2
# var b="textvar"
var anim

func _ready():
	set_process(true)
	anim = get_node("door_spatial/AnimationPlayer")

func _process(delta):
	if(anim.is_playing()):
		if(get_node("door_spatial/door/col").get_colliding_bodies().size > 0):
			anim.stop(false)
			
	


