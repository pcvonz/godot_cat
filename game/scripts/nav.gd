#success is more try than cry

extends Navigation

# The state machine consists of two actions. 
# One part oves the path (move_*()
# The other part is for updating the cat's path (go_to_bathroom, go_to_food(), etc).

var anim
var path = []
var begin = Vector3()
var end = Vector3()
var cat
var obs


var hunger_limit = 40
var hunger = 0
var time = 0
var arrive = true

var stomach = [2, 2, 2]
var energy = 100

#Wait while wandering
var wait = 0
var elapsed_wait_time = 0

var sitting = false
var eating = false

var sleeping = false
var elapsed_sleep_time = 0
var sleep = 0

var littering = false
var elapsed_litter_time = 0
var litter = 0
var bowels_full = false

func _process(delta):
	
	time = time + delta
	elapsed_wait_time = elapsed_wait_time + delta
	elapsed_sleep_time = elapsed_sleep_time + delta
	elapsed_litter_time = elapsed_litter_time + delta
	obs.get_node("litter").set_text(str("littering ", littering))
	obs.get_node("sit").set_text(str("sitting ", sitting))
	obs.get_node("food").set_text(str("eating ", eating))
	obs.get_node("sleep").set_text(str("sleeping ", sleeping))
	obs.get_node("energy").set_text(str("energy ", energy))
	obs.get_node("path").set_text(str(path))
	obs.get_node("stomach").set_text(str("stomach ", stomach))
	#Sleeps first,
	#Litters second	
	#Eats third
	#Wanders and sits elsewise
	if(energy < 0):
		sleep()
	elif bowels_full == true:
		go_to_bathroom()
		move_cat()
	elif(hunger > hunger_limit and stomach.size() < 3 and not sitting):
		get_food()
		move_cat()
	else:
		energy = energy - delta
		wander()
		move_cat_wander()
	if (stomach.size() <= 3):
		hunger = delta + hunger
	if(stomach.size() > 0):
		if(stomach[0] <= 0):
			bowels_full = true
		else:
			stomach[0] = stomach[0] - delta

func go_to_bathroom():
	if end != get_closest_point(get_node("Room/litter_box").get_translation()):
		arrive = false
		end = get_closest_point(get_node("Room/litter_box").get_translation())
		_update_path()
	if(arrive == true):
		arrive = false
		litter()
		
func litter():
	cat.get_node("Spatial/AnimationPlayer").get_animation("walk").set_loop(false)
	if(not cat.get_node("Spatial/AnimationPlayer").is_playing() and not littering):
		anim.play("litter")
		randomize()
		litter = rand_range(10, 20)
		elapsed_litter_time = 0
		littering = true
	elif(littering == true and litter < elapsed_litter_time):
		littering = false
		bowels_full = false
		stomach.pop_front()
		_update_path()

func move_cat():
	if (path.size()>0):
		if(cat.get_translation().distance_to(path[path.size()-1]) > 2):
			cat.seek_point = path[path.size()-1]
		else:
			path.remove(path.size()-1)
	else:
		arrive = true

func sleep():
	if not sleeping:
		sleeping = true
		randomize()
		elapsed_sleep_time = 0
		sleep = rand_range(5, 10)
		anim.play("sleep")
	else:
		if(elapsed_sleep_time > sleep):
			sleeping = false
			energy = 50
			

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
		elapsed_wait_time = 0
		sitting = true
	elif(sitting == true and wait < elapsed_wait_time):
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
			wander()
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

#animation signal they aren't really used yet. 
func anim_changed(old_name, new_name):
	print(old_name, new_name)

#animation signal they aren't really used yet. 
func anim_finish():
	pass
	
func save():
	var savedict = {
		filename = get_filename(),
		parent = get_parent().get_path(),
		time = time,
		hunger = hunger,
		stomach = stomach,
		energy = energy,
		elapsed_sleep_time = elapsed_sleep_time,
		sleep = sleep,
		elapsed_litter_time = elapsed_litter_time,
		litter = litter,
		bowels_full = bowels_full,
		previous_time = OS.get_datetime()
	}
	return savedict

func _ready():
	cat = get_node("../cat")
	print(cat)
	anim = cat.get_node("Spatial/AnimationPlayer")
	anim.connect("animation_changed", self, "anim_changed")
	anim.connect("finished", self, "anim_finish")
	obs = get_node("../Observer/Spatial/Camera")
	set_process_input(true)
	set_process(true)
	wander()
	add_to_group("Persist", true)
	_update_path()

