#success is more try than cry

extends Navigation

# The state machine consists of two actions. 
# One part oves the path (move_*()
# The other part is for updating the cat's path (go_to_bathroom, go_to_food(), etc).


#I should probably separate all the stuff into a cat class (Reference the ai book)
var anim
var path = []
var begin = Vector3()
var end = Vector3()
var cat
var obs

var food_bowl
var water_bowl

var hunger_limit = 60*60*3
var hunger = hunger_limit
var thirst_limit = 60*60*2
var thirst = thirst_limit

var time = 0
var arrive = true

var stomach = []
var energy = 100

var bladder = []

#Wait while wandering
var wait = 0
var elapsed_wait_time = 0

var sitting = false
var eating = false
var drinking = false
var food_count = 3
var water_count = 3
var starved = false

var sleeping = false
var elapsed_sleep_time = 0
var sleep = 0
var littering = false
var elapsed_litter_time = 0
var litter = 0
var stomach_full = false
var bladder_full = false
var previous_time = OS.get_unix_time()

var sleep_max = 60*60*1
var updated = false
var food_in_bowl = true
var water_in_bowl = true
var pos_x
var pos_y
var pos_z
var hud = true
var petting = false

func _process(delta):
	if ((OS.get_unix_time() - previous_time) > 0) and not updated:
		var time_since_last_played = OS.get_unix_time() - previous_time
		update_stat(energy, time_since_last_played, sleep_max)
		update_digestion(stomach, time_since_last_played)
		hunger = update_thirst(hunger, time_since_last_played)
		thirst = update_thirst(thirst, time_since_last_played)
		if(sleeping):
			elapsed_sleep_time += time_since_last_played
		if(pos_z):
			var cat_loc = Vector3(pos_x, pos_y, pos_z)
			cat.set_translation(cat_loc)
		get_node("Room/spatial_bowl_food/food").set_flag(0, food_in_bowl)
		get_node("Room/spatial_bowl_water/water").set_flag(0, water_in_bowl)
		updated = true
	
	time = time + delta
	elapsed_wait_time = elapsed_wait_time + delta
	if(sleeping):
		elapsed_sleep_time = elapsed_sleep_time + delta
	print(elapsed_sleep_time)
	elapsed_litter_time = elapsed_litter_time + delta
	if(hud == true):
		update_hud()
	#Sleeps first,
	#Litters second
	#Eats third
	#Wanders and sits elsewise
	if(hunger < -1000 or thirst < -1000):
		die()
	elif(energy < 0):
		if not petting:
			sleep()
		else:
			sleep_meow()
	elif stomach_full == true:
		go_to_bathroom()
		move_cat()
	elif(thirst < 0 and bladder.size() < 3 and not sitting):
		if(water_bowl.get_node("water").get_flag(0)):
			get_water()
		else:
			whine()
		move_cat()
	elif(hunger < 0 and stomach.size() < 3 and not sitting):
		if(food_bowl.get_node("food").get_flag(0)):
			get_food()
		else:
			whine()
		move_cat()
	else:
		energy = energy - delta
		wander()
		move_cat_wander()
	if (stomach.size() <= 3):
		hunger = hunger - delta
	if (bladder.size() <= 3):
		thirst = thirst - delta
	if (bladder.size() > 0):
		if(bladder[0] <= 0):
			bladder_full = true
		else:
			bladder[0] = bladder[0] - delta
	if(stomach.size() > 0):
		if(stomach[0] <= 0):
			stomach_full = true
		else:
			stomach[0] = stomach[0] - delta

func sleep_meow():
	petting = true

func update_hud():
	obs.get_node("litter").set_text(str("littering ", littering))
	obs.get_node("sit").set_text(str("sitting ", sitting))
	obs.get_node("food").set_text(str("eating ", eating))
	obs.get_node("sleep").set_text(str("sleeping ", sleeping))
	obs.get_node("energy").set_text(str("energy ", energy))
	obs.get_node("path").set_text(str(path))
	obs.get_node("stomach").set_text(str("stomach ", stomach))
	obs.get_node("bladder").set_text(str("bladder ", bladder))
	obs.get_node("hunger").set_text(str("hunger ", hunger))
	obs.get_node("thirst").set_text(str("thirst ", thirst))

#need to take into account stomach

func die():
	print("dying and dead")

func update_thirst(thirst, time_since):
	while(time_since > 0):
		if(time_since > thirst):
			thirst = 0
			time_since = 0
		else:
			thirst = thirst - time_since
			time_since = 0
	return thirst

func update_digestion(digest, time_since):
	for i in range(0, digest.size() -1):
		if(digest[i] < time_since):
			digest[i]

func update_stat(stat, time_since, stat_max):
	if time_since > stat_max*2:
		if((int(time_since) % stat_max*2) > 50):
			return 0
		else:
			return time_since % stat_max
	else:
		return stat - time_since

func go_to_bathroom():
	if end != get_closest_point(get_node("Room/litter_box").get_translation()):
		arrive = false
		end = get_closest_point(get_node("Room/litter_box").get_translation())
		_update_path()
	if(arrive == true):
		litter()
		
func litter():
	cat.get_node("Spatial/AnimationPlayer").get_animation("walk").set_loop(false)
	if(not cat.get_node("Spatial/AnimationPlayer").is_playing() and not littering):
		anim.play("litter")
		randomize()
		litter = rand_range(0, 5)
		elapsed_litter_time = 0
		littering = true
	elif(littering == true and litter < elapsed_litter_time):
		littering = false
		stomach_full = false
		elapsed_litter_time = 0
		arrive = false
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
		sleep = rand_range(60*60*2, 60*60*2.2)
		anim.play("sleep")
	else:
		if(elapsed_sleep_time > sleep):
			sleeping = false
			energy = sleep_max
			elapsed_sleep_time = 0

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
		wait = rand_range(1, 20)
		elapsed_wait_time = 0
		sitting = true
	elif(sitting == true and wait < elapsed_wait_time):
		sitting = false
		_update_path()
		
func get_food():
	if end != get_closest_point(get_node("Room/spatial_bowl_food").get_translation()):
#For food and water, investigate whether or not I need to change the following line:
#I believe it should use the get_flag method.
		if(get_node("Room/spatial_bowl_food/food").get_flag(0)):
			arrive = false
			end = get_closest_point(get_node("Room/spatial_bowl_food").get_translation())
			_update_path()
		else:
			whine()
	if(arrive == true):
		arrive = false
		eat()

func get_water():
	if end != get_closest_point(get_node("Room/spatial_bowl_water").get_translation()):
		print(get_node("Room/spatial_bowl_water/water").get_flag(0))
		if(get_node("Room/spatial_bowl_water/water").get_flag(0)):
			arrive = false
			end = get_closest_point(get_node("Room/spatial_bowl_water").get_translation())
			_update_path()
		else:
			whine()
	if(arrive == true):
		arrive = false
		drink_water()

func whine():
	if(end != get_closest_point(get_node("../Observer").get_translation())):
		print("WHINE")
		end = get_closest_point(get_node("../Observer").get_translation())
		_update_path()
	
#Use signal to trigger something after animation ends?
func eat():
	cat.get_node("Spatial/AnimationPlayer").get_animation("walk").set_loop(false)
	if(not cat.get_node("Spatial/AnimationPlayer").is_playing() and not eating ):
		anim.play("eat")
		eating = true
	elif(eating == true):
		if(not cat.get_node("Spatial/AnimationPlayer").is_playing()):
			food_count = food_count - 1
			if(food_count == 0):
				get_node("Room/spatial_bowl_food/food").set_flag(0, false)
			eating = false
			wander()
			_update_path()
			hunger = hunger_limit
			digest_food()

func drink_water():
	cat.get_node("Spatial/AnimationPlayer").get_animation("walk").set_loop(false)
	if(not cat.get_node("Spatial/AnimationPlayer").is_playing() and not drinking ):
		anim.play("eat")
		drinking = true
	elif(drinking == true):
		if(not cat.get_node("Spatial/AnimationPlayer").is_playing()):
			water_count = water_count - 1 
			if(water_count == 0):
				get_node("Room/spatial_bowl_water/water").set_flag(0, false)
			drinking = false
			wander()
			_update_path()
			thirst = thirst_limit
			digest_water()

func digest_food():
	randomize()
	stomach.append(rand_range(60*60*3,60*60*4))
	
func digest_water():
	randomize()
	bladder.append(rand_range(60*60*3,60*60*3.5))
	
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
		thirst = thirst,
		stomach = stomach,
		energy = energy,
		elapsed_sleep_time = elapsed_sleep_time,
		sleep = sleep,
		sleeping = sleeping,
		elapsed_litter_time = elapsed_litter_time,
		litter = litter,
		stomach_full = stomach_full,
		food_in_bowl = get_node("Room/spatial_bowl_food/food").get_flag(0),
		water_in_bowl = get_node("Room/spatial_bowl_water/water").get_flag(0),
		previous_time = OS.get_unix_time(),
		pos_x = cat.get_translation().x,
		pos_y = cat.get_translation().y,
		pos_z = cat.get_translation().z,
		food_count = food_count,
		water_count = water_count
	}
	return savedict
	
func pet(camera, event, click_pos, click_normal, shape_idx):
	if(event.is_action("interact")):
		petting = true

func _ready():
	cat = get_node("../cat")
	cat.connect("input_event", self, "pet")
	print(cat)
	anim = cat.get_node("Spatial/AnimationPlayer")
	anim.connect("animation_changed", self, "anim_changed")
	anim.connect("finished", self, "anim_finish")
	obs = get_node("../Observer/Spatial/Camera")
	food_bowl = get_node("Room/spatial_bowl_food")
	water_bowl = get_node("Room/spatial_bowl_water")
	set_process_input(true)
	set_process(true)
	wander()
	add_to_group("Persist", true)
	_update_path()

