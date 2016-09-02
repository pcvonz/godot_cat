
extends Navigation

# member variables here, example:
# var a=2
# var b="textvar"
var path = []
var begin = Vector3()
var end = Vector3()
var cat
var count = 0
var hunger_limit = 60
var time = 0
var arrive = true
var fetching_food = false
var hunger = 0
var stomach = []
var energy = 50

func _process(delta):
	time = time + delta
	if (stomach.size() < 3):
		hunger = delta + hunger
	if(stomach.size() >0):
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

func go_to_bathroom():
#	print("Bathroom")
	stomach.pop_front()

func move_cat():
	if (path.size()>0):
		count+= 1
		if(cat.get_translation().distance_to(path[path.size()-1]) > 2):
			cat.seek_point = path[path.size()-1]
		else:
#			print(path[path.size()-1])
			path.remove(path.size()-1)
	else:
		arrive = true

func move_cat_wander():
	if (path.size()>0):
		count+= 1
		if(cat.get_translation().distance_to(path[path.size()-1]) > 2):
			cat.seek_point = path[path.size()-1]
		else:
#			print(path[path.size()-1])
			path.remove(path.size()-1)
	else:
		sit()
		
func sit():
#	print("Sitting")
	cat.get_node("Spatial/AnimationPlayer").get_animation("default").set_loop(false)
#	print(cat.get_node("Spatial/AnimationPlayer").is_playing())
	if(not cat.get_node("Spatial/AnimationPlayer").is_playing()):
#		print("HELJKSD:FLKJ")
		_update_path()

func get_food():
#	print("Getting food")
	if end != get_closest_point(get_node("Room/bowl-water").get_translation()):
		arrive = false
		end = get_closest_point(get_node("Room/bowl-water").get_translation())
		_update_path()
	if(arrive == true):
		arrive = false
		eat()

#Use signal to trigger something after animation ends?
func eat():
#	print("Eating")
	hunger = 0
	digest_food()

func digest_food():
	randomize()
	stomach.append(rand_range(120, 150))

func wander():
#	print("wandering")
	var nav_points = get_node("Room/nav_empty").get_children()
	randomize()
	end = get_closest_point(nav_points[rand_range(0, nav_points.size() - 1)].get_translation())
	
func _update_path():
	cat.get_node("Spatial/AnimationPlayer").get_animation("default").set_loop(true)
	cat.get_node("Spatial/AnimationPlayer").play("default")
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

func _ready():
	cat= get_node("../cat")
	set_process_input(true)
	set_process(true)
	wander()
	_update_path()

