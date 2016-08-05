
extends RigidBody

# member variables here, example:
# var a=2
# var b="textvar"

#var MAX_SPEED = 7
#var target
#func _fixed_process(delta):
#	var mat = get_global_transform().basis
#	var vec = get_global_transform().origin
#	target = get_node("../Camera").project_position(get_viewport().get_mouse_pos())
#	apply_impulse(get_global_transform().origin, seek(target))
#
#Flocking behavior stuff..
#func seek(target):
#	var desired_vec = Vector3(target.x, 0, target.y) - get_global_transform().origin
#	desired_vec = desired_vec.normalized() * MAX_SPEED
#	look_at(Vector3(target.x, 0, target.y), Vector3(0, 1, 0))
#	return(desired_vec - get_linear_velocity())
#
#func _ready():
#	target  = get_global_transform().origin
#	set_fixed_process(true)


