
extends RigidBody
signal door

signal tty
signal lamp
# Member variables
var r_pos = Vector2()
var state
var velocity = Vector3(0,0,0)
const STATE_MENU = 0
const STATE_GRAB = 1
var mov_speed = 5
var ray


#Variable set to seek cats towards you
var calling = false	

func direction(vector):
	#The spacial is like the body. It doesn't rotate and get stuck on the ground.
	var v = get_node("Spatial").get_global_transform().basis*vector
	v = v.normalized()
	return v

func impulse(event, action):
	if(event.is_action(action) && event.is_pressed() && !event.is_echo()):
		return true
	else:
		return false

func _fixed_process(delta):
	if(state != STATE_GRAB):
		return

	if(Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	var dir = Vector3()
	var cam = get_global_transform()
	var org = get_translation()
	
	#Direction orients the vector 
	if (Input.is_action_pressed("move_forward")):
		dir = direction(Vector3(0, 0, -mov_speed))
	if (Input.is_action_pressed("move_backward")):
		dir = direction(Vector3(0, 0, mov_speed))
	if (Input.is_action_pressed("move_left")):
		dir = direction(Vector3(-mov_speed, 0, 0))
	if (Input.is_action_pressed("move_right")):
		dir = direction(Vector3(mov_speed, 0, 0))
	if(get_colliding_bodies().size() == 0):
		set_linear_velocity(get_linear_velocity())
	else:
		set_linear_velocity(dir*mov_speed)
	var d = delta*0.1
	
	var yaw = get_transform().rotated(Vector3(0, 1, 0), d*r_pos.x)
	set_transform(yaw)
	
	var cam = get_node("Spatial/Camera")
	var pitch = cam.get_transform().rotated(Vector3(1, 0, 0), d*r_pos.y)
	cam.set_transform(pitch)
	
	r_pos.x = 0.0
	r_pos.y = 0.0
	get_viewport().get_mouse_pos()


func _input(event):
	if(event.type == InputEvent.MOUSE_MOTION):
		r_pos = event.relative_pos
	if(event.is_action_pressed('interact')):
#		var from = get_node("Spatial/Camera").project_ray_origin(event.pos)
#		var to = from+get_node("Spatial/Camera").project_ray_normal(event.pos)*100
		
#		get_node('Spatial/Camera/RayCast 2').set_global_transform(Transform(get_global_transform().basis, from))
#		get_node('Spatial/Camera/RayCast 2').set_cast_to(to)
		if get_node('Spatial/Camera/RayCast 2').is_colliding():
			var object = get_node('Spatial/Camera/RayCast 2').get_collider().get_parent()
			print(object.get_name())
			emit_signal(object.get_name(), object)
#		if calling == true:
#			calling = false
#		else:
#			calling = true
			
			
	if(impulse(event, "ui_cancel")):
		if(state == STATE_GRAB):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			state = STATE_MENU
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			state = STATE_GRAB



func _ready():
	set_fixed_process(true)
	set_process_input(true)
	state = STATE_GRAB
