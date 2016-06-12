
extends RigidBody

# member variables here, example:
# var a=2
# var b="textvar"

export(int, FLAGS, "fast", "normal", "slow") var decel = 1

var max_speed
var max_turn_rate
var mass
var max_force
var velocity

func flee(target, object):
	var desired_vec = object.get_global_transform().origin - target.get_global_transform().origin
	desired_vec = desired_vec.normalized() * max_speed
	return(desired_vec - object.get_linear_velocity())

func seek(target, object):
	var desired_vec = target.get_global_transform().origin - object.get_global_transform().origin
	desired_vec = desired_vec.normalized() * max_speed
	return(desired_vec - object.get_linear_velocity())
	
func seek_pos(target, object):
	var desired_vec = target.normalized() * max_speed
	return(desired_vec - object.get_linear_velocity())

#takes in a with different speeds (slow, normal, fast)
func arrive(target, deceleration, object):
	var target_vec = target.get_global_transform().origin
	var curr_vec = object.get_global_transform().origin
	var vec_to = target_vec - curr_vec
	var distance_to = vec_to.length()
	
	if distance_to > 2:
		var decel_tweak = 0.3
		var speed = distance_to / decel * decel_tweak
		#Make sure speed doesn't exceed the max speed
		min(speed, max_speed)
		var desired_vec = vec_to * speed / distance_to
		return(desired_vec - object.get_linear_velocity())
	return(-object.get_linear_velocity())

func pursuit(evader, object):
	#If the evader is in front of the seeker, then just seek
	var evader_pos = evader.get_global_transform().origin
	var curr_pos = object.get_global_transform().origin
	var relative_heading = object.get_rotation().dot(evader.get_rotation())
	if(curr_pos.distance_to(evader_pos) > 0 and relative_heading < -0.95):
		return seek(evader, object)
	else:
		var look_ahead_time = curr_pos.distance_to(evader_pos) / (max_speed + evader.MAX_SPEED)
		return seek_pos(evader_pos + evader.get_linear_velocity() * look_ahead_time, object)

#func wander(object):
	
	

func _init(mass, max_speed, max_force, max_turn_rate):
	self.mass = mass
	self.max_speed = max_speed
	self.max_force = max_force
	self.max_turn_rate = max_turn_rate
	self.velocity = velocity