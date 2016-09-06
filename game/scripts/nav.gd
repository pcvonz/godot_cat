
extends Navigation

# member variables here, example:
# var a=2
# var b="textvar

var anim
var path = []
var begin = Vector3()
var end = Vector3()
var cat



var hunger_limit = 10
var hunger = 0
var time = 0
var arrive = true

var stomach = []
var energy = 50

#Wait while wandering
var wait = 0
var wait_time = 0

var sitting = false
var eating = false

func _process(delta):
	time = time + delta
	wait_time = wait_time + delta
	if (stomach.size() < 3):
		hunger = delta + hunger
	if(stomach.size() > 0):
		if(stomach[0] <= 0):
			go_to_bathroom()
		else:
			stomach[0] = stomach[0] - delta
	if(hunger > hunger_limit and stomach.size() <= 3):
		get_food()
		move_cat()
	elif energy > 0:
		wander()
		energy = energy - delta
		move_cat_wander()
	print(stomach)

func go_to_bathroom():
	stomach.pop_front()

func move_cat():
	if (path.size()>0):
		if(cat.get_translation().distance_to(path[path.size()-1]) > 2):
			cat.seek_point = path[path.size()-1]
		else:
			path.remove(path.size()-1)
	else:
		arrive = true

func move_cat_wander():
	if (path.size()>0):
		if(cat.get_translation().distance_to(path[path.size()-1]) > 2):
			cat.seek_point = path[path.size()-1]
		else:
			path.remove(path.size()-1)
	else:
		sit()

func sit():
	cat.get_node("Spatial/AnimationPlayer").get_animation("walk").set_loop(false)
	if(not cat.get_node("Spatial/AnimationPlayer").is_playing() and not sitting ):
		anim.play("sit")
		randomize()
		wait = rand_range(10, 20)
		wait_time = 0
		sitting = true
	elif(sitting == true and wait < wait_time):
		sitting = false
		_update_path()
		

func get_food():
	if end != get_closest_point(get_node("Room/bowl-water").get_translation()):
		arrive = false
		end = get_closest_point(get_node("Room/bowl-water").get_translation())
		_update_path()
	if(arrive == true):
		arrive = false
		eat()

#Use signal to trigger something after animation ends?
func eat():
	cat.get_node("Spatial/AnimationPlayer").get_animation("walk").set_loop(false)
	if(not cat.get_node("Spatial/AnimationPlayer").is_playing() and not eating ):
		anim.play("eat")
		eating = true
	elif(eating == true):
		if(not cat.get_node("Spatial/AnimationPlayer").is_playing()):
			eating = false
			_update_path()
			hunger = 0
			digest_food()

func digest_food():
	randomize()
	stomach.append(rand_range(120, 150))

func wander():
	var nav_points = get_node("Room/nav_empty").get_children()
	randomize()
	end = get_closest_point(nav_points[rand_range(0, nav_points.size() - 1)].get_translation())
	
func _update_path():
	cat.get_node("Spatial/AnimationPlayer").get_animation("walk").set_loop(true)
	cat.get_node("Spatial/AnimationPlayer").play("walk")
	begin = get_closest_point(cat.get_translation())
	var p = get_simple_path(begin, end, true)
	path=Array(p)
	path.invert()
	
	
func _input(ev):
	if (ev.type==InputEvent.MOUSE_BUTTON and ev.button_index==BUTTON_LEFT and ev.pressed):
#		var from = get_node("../Observer/Spatial/Camera").project_ray_origin(ev.pos)
#		var to = from+get_node("../Observer/Spatial/Camera").project_ray_normal(ev.pos)*100
#		end = get_closest_point_to_segment(from,to)
#		get_node("targ").set_global_transform(Transform(get_node("targ").get_global_transform().basis, end))
		wander()
#		print(get_node("Room/nav").get_global_transform().basis)
		_update_path()

#animation signals they aren't really used yet. 
func anim_changed(old_name, new_name):
	print(old_name, new_name)

#animation signals they aren't really used yet. 
func anim_finish():
	print('ehllo')

func _ready():
	cat = get_node("../cat")
	print(cat)
	anim = cat.get_node("Spatial/AnimationPlayer")
	anim.connect("animation_changed", self, "anim_changed")
	anim.connect("finished", self, "anim_finish")
	set_process_input(true)
	set_process(true)
	wander()
	_update_path()

