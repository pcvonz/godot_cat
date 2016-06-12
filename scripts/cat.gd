
extends RigidBody

# member variables here, example:
# var a=2
# var b="textvar"

var Vehicle = load("scripts/Vehicle.gd")
var target

func _fixed_process(delta):
	Vehicle.update(delta, target, self)
	set_linear_velocity(Vehicle.velocity)

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	target = get_node("../target")
	#mass, max_speed, max_force, max_turn_rate
	Vehicle = Vehicle.new(10, 7, 4, 1)
	set_fixed_process(true)
	


