
extends Node

# member variables here, example:
# var a=2
# var b="textvar"

var heading
var velocity = Vector3(0, 0, 0)
var side
var MASS
var MAX_SPEED
var MAX_FORCE
var MAX_TURN_RATE
var Steering = load("/scripts/steering.gd")

func update(time_elapsed, target, object):
	var SteeringForce = Steering.seek(target, object)
	#f=ma -> a=f/a
	var acceleration = SteeringForce / MASS
	velocity  += acceleration * time_elapsed
	#Need to figure out a way to truncate a vector
	if velocity.length() > MAX_SPEED:
		 velocity = velocity.normalized()*MAX_SPEED
	#position += velocity * time_elapsed
	
	#Update the heading
	if velocity.length_squared() > .00000001:
		heading = velocity.normalized()
		#Need to calc the perp
		
	object.look_at(object.get_global_transform().origin + object.get_linear_velocity().normalized(), Vector3(0, 1, 0))


func _init(mass, max_speed, max_force, max_turn_rate):
	MASS = mass
	MAX_SPEED = max_speed
	MAX_FORCE = max_force
	MAX_TURN_RATE = max_turn_rate
	Steering = Steering.new(mass, max_speed, max_force, max_turn_rate)


