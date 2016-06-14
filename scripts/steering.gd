
extends RigidBody

# member variables here, example:
# var a=2
# var b="textvar"

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
func arrive(target, decel, object):
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
	var to_evader = evader_pos - curr_pos
	var relative_heading = object.get_rotation().dot(evader.get_rotation())
	if( to_evader.dot(object.Vehicle.heading) > 0 and relative_heading < -0.95):
		return seek(evader, object)
	else:
		var look_ahead_time = to_evader.length() / (max_speed + evader.get_linear_velocity().length())
		var pursuit_targ = object.get_node("TestCube")
		pursuit_targ.set_global_transform(Transform(pursuit_targ.get_transform().basis, (evader_pos + evader.get_linear_velocity() * look_ahead_time)))
		return seek(pursuit_targ, object)

func evade(pursuer, object):
	#If the evader is in front of the seeker, then just seek
	var pursuer_pos = pursuer.get_global_transform().origin
	var curr_pos = object.get_global_transform().origin
	var to_pursuer = pursuer_pos - curr_pos
	var look_ahead_time = to_pursuer.length() / (max_speed + pursuer.get_linear_velocity().length())
	var evade_targ = object.get_node("TestCube")
	evade_targ.set_global_transform(Transform(evade_targ.get_transform().basis, (pursuer_pos + pursuer.get_linear_velocity() * look_ahead_time)))
	return flee(evade_targ, object)

func wander(object, wander_object, wander_radius, wander_distance, wander_jitter):
	randomize()
	var wander_target = wander_object.get_transform().origin
	wander_target += Vector3(rand_range(-1, 1) * wander_jitter, 0, rand_range(-1, 1) * wander_jitter)
	wander_target = wander_target.normalized()
	wander_target *= wander_radius
	#reprojecting 
	var target_local = wander_target + Vector3(0, 0, -wander_distance)
	wander_object.set_transform(Transform(wander_object.get_transform().basis, target_local))
	return seek(wander_object, object)
	
func wall_avoid(object, RayLeft, RayCenter, RayRight):
	var SteeringForce = Vector3(0, 0, 0)
	if RayLeft.get_collider():
		SteeringForce += calc_wall_vel(object, RayLeft)
	if RayCenter.get_collider():
		SteeringForce += calc_wall_vel(object, RayCenter)
	if RayRight.get_collider():
		SteeringForce += calc_wall_vel(object, RayRight)
	return SteeringForce

func calc_wall_vel(object, ray):
	#The rays are actually a little closer, thus I add 1
	var dist_to_col = (ray.get_collision_point() - object.get_global_transform().origin)
	var overshoot = dist_to_col - ray.get_cast_to()
	#Creating a steering force in the direction of the wall normal with the magnitude
	#of the overshoot
	return ray.get_collision_normal() * overshoot.length() 

func _init(mass, max_speed, max_force, max_turn_rate):
	self.mass = mass
	self.max_speed = max_speed
	self.max_force = max_force
	self.max_turn_rate = max_turn_rate
	self.velocity = velocity