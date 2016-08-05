
extends Node

# member variables here, example:
# var a=2
# var b="textvar"

var heading = Vector3(0, 0, 0)
var velocity = Vector3(0, 0, 0)
var side
var MASS
var MAX_SPEED
var MAX_FORCE
var MAX_TURN_RATE
var Steering = load("/scripts/steering.gd")

func update(time_elapsed, SteeringForce):
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
		


func _init(mass, max_speed, max_force, max_turn_rate):
	MASS = mass
	MAX_SPEED = max_speed
	MAX_FORCE = max_force
	MAX_TURN_RATE = max_turn_rate
	#Steering = Steering.new(mass, max_speed, max_force, max_turn_rate)


