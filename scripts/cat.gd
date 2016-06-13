
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
export(int, FLAGS, "Seek", "flee", "Pursuit", "Evade", "Wander") var flock_type
export(NodePath) var target

var Vehicle = load("scripts/Vehicle.gd")
var Steering = load("/scripts/steering.gd")

func _fixed_process(delta):
	var SteeringForce = Vector3(0.0, 0, 0)
	if flock_type & 1:
		SteeringForce += Steering.seek(target, self)
	if flock_type & 2:
		SteeringForce += Steering.flee(target, self)
	if flock_type & 4:
		SteeringForce += Steering.pursuit(target, self)
	if flock_type & 8:
		SteeringForce += Steering.evade(target, self)
#	#object, wander_object, wander_radius, wander_distance, wander_jitter
	if flock_type & 16:
		SteeringForce += Steering.wander(self, get_node("TestCube"), wander_radius, wander_distance, wander_jitter)
	Vehicle.update(delta, SteeringForce)
	set_linear_velocity(Vehicle.velocity)
	
	#Set the objects orientationt to the current heading
	look_at(get_global_transform().origin + get_linear_velocity().normalized(), Vector3(0, 1, 0))

func _enter_tree():
	set_fixed_process(true)
func _ready():
	target = get_node(target)
	Vehicle = Vehicle.new(mass, max_speed, max_force, max_turn_rate)
	Steering = Steering.new(mass, max_speed, max_force, max_turn_rate)
	


