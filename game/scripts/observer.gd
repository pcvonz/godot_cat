
extends Spatial

# Member variables
var r_pos = Vector2()
var state
var velocity = Vector3(0,0,0)
const STATE_MENU = 0
const STATE_GRAB = 1
var speed = .0002
var ray

var MASS = 4000
var MAX_SPEED = 20


#Variable set to seek cats towards you
var calling = false

func update(time_elapsed, force):
	#f=ma -> a=f/a
	var acceleration = force / MASS
	velocity  += acceleration * time_elapsed
	#Need to figure out a way to truncate a vector
	if velocity.length() > MAX_SPEED:
		 velocity = velocity.normalized()*MAX_SPEED
	#position += velocity * time_elapsed
	

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
	if ray.is_colliding():
		update(delta, ray.get_collision_point() - get_global_transform().origin)
		move(velocity)
	
	if(state != STATE_GRAB):
		return
	var space_state = get_world().get_direct_space_state()
#	var result = space_state.intersect_ray( get_global_transform().origin, get_parent().get_node('Floor').get_global_transform().origin, [self])
#	print(result)
	if(Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	var dir = Vector3()
	var cam = get_global_transform()
	var org = get_translation()
	
	if (Input.is_action_pressed("move_forward")):
		dir += direction(Vector3(0, 0, -speed))
	if (Input.is_action_pressed("move_backward")):
		dir += direction(Vector3(0, 0, speed))
	if (Input.is_action_pressed("move_left")):
		dir += direction(Vector3(-speed, 0, 0))
	if (Input.is_action_pressed("move_right")):
		dir += direction(Vector3(speed, 0, 0))
	if (Input.is_action_pressed("jump")):
		##jump?
		pass
	
	dir = dir.normalized()
	
	move(dir*10*delta)
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
	if(event.is_action_pressed('mouse_click')):
		if get_node('Spatial/Camera/RayCast 2').is_colliding():
			print(get_node('Spatial/Camera/RayCast 2').get_collider().get_name())
		if calling == true:
			calling = false
		else:
			calling = true
			
			
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
	ray = get_node("RayCast")
	state = STATE_GRAB
