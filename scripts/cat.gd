
extends RigidBody

# member variables here, example:
# var a=2
# var b="textvar"

export(int, FLAGS, "fast", "normal", "slow") var decel = 1
export var max_speed = 1.0
export var mass = 50.0
export var max_force = 1.0
export var max_turn_rate = 1.0
export var wander_radius = 1.0
export var wander_distance = 1.0
export var wander_jitter = 1.0
export(int, FLAGS, "Seek", "flee", "Pursuit", "Evade", "Wander", "Wall Avoid", "Object Avoid") var flock_type
export(NodePath) var target

var Vehicle = load("scripts/Vehicle.gd")
var Steering = load("/scripts/steering.gd")

#Setting up rays
var RayLeft
var RayRight
var RayCenter
var ObjectAvoidArea


func _fixed_process(delta):
	var SteeringForce = Vector3(0, 0, 0)
	if flock_type & 1:
		SteeringForce += Steering.seek(target, self)
	if flock_type & 2:
		SteeringForce += Steering.flee(target, self)
	if flock_type & 4:
		SteeringForce += Steering.pursuit(target, self)
	if flock_type & 8:
		SteeringForce += Steering.evade(target, self)
	#object, wander_object, wander_radius, wander_distance, wander_jitter
	if flock_type & 16:
		SteeringForce += Steering.wander(self, get_node("TestCube"), wander_radius, wander_distance, wander_jitter)
	if flock_type & 32:
		if RayLeft.get_collider() or RayCenter.get_collider() or RayRight.get_collider():
			#Sanitize the y vector
			SteeringForce += Steering.wall_avoid(self, RayLeft, RayCenter, RayRight)
			#Steering.wall_avoid(self, RayLeft, RayCenter, RayRight)
	if flock_type & 64:
		#if RayObjectAvoid1.get_collider() or RayObjectAvoid2.get_collider():
		if ObjectAvoidArea.get_overlapping_bodies().size() > 0:
			SteeringForce += Steering.object_avoid(self, ObjectAvoidArea)
			#Steering.object_avoid(self, RayObjectAvoid1, RayObjectAvoid2)
	var temp = SteeringForce
	SteeringForce = Vector3(temp.x, 0, temp.z)
	
	Vehicle.update(delta, SteeringForce)
	set_linear_velocity(Vehicle.velocity)
	
	#Set the objects orientationt to the current heading
	look_at(get_global_transform().origin + get_linear_velocity().normalized(), Vector3(0, 1, 0))

func _enter_tree():
	set_fixed_process(true)
func _ready():
	RayLeft = get_node("RayLeft")
	RayRight = get_node("RayRight")
	RayCenter = get_node("RayCenter")
	ObjectAvoidArea = get_node("Area")
	RayLeft.add_exception(self)
	RayCenter.add_exception(self)
	RayRight.add_exception(self)
	target = "../target"
	target = get_node(target)
	Vehicle = Vehicle.new(mass, max_speed, max_force, max_turn_rate)
	Steering = Steering.new(mass, max_speed, max_force, max_turn_rate)
	


