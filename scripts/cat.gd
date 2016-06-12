
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

var Vehicle = load("scripts/Vehicle.gd")
var Steering = load("/scripts/steering.gd")
var target

func _fixed_process(delta):
	var SteeringForce = Steering.seek(target, self)
	#object, wander_object, wander_radius, wander_distance, wander_jitter
	#var SteeringForce = Steering.wander(self, get_node("TestCube"), wander_radius, wander_distance, wander_jitter)	
	Vehicle.update(delta, SteeringForce)
	set_linear_velocity(Vehicle.velocity)
	
	#Set the objects orientationt to the current heading
	look_at(get_global_transform().origin + get_linear_velocity().normalized(), Vector3(0, 1, 0))

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	target = get_node("../target")
	#mass, max_speed, max_force, max_turn_rate
	Vehicle = Vehicle.new(mass, max_speed, max_force, max_turn_rate)
	set_fixed_process(true)
	Steering = Steering.new(mass, max_speed, max_force, max_turn_rate)
	


