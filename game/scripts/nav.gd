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

var food_bowl
var water_bowl

var hunger_limit = 1
var hunger = 0
var thirst_limit = 1
var thirst = 0

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

func _process(delta):
	if ((OS.get_unix_time() - previous_time) > 0) and not updated:
		var time_since_last_played = OS.get_unix_time() - previous_time
		update_stat(energy, time_since_last_played, sleep_max)
		update_digestion(stomach, time_since_last_played)
		hunger = update_hunger(hunger, time_since_last_played)
		thirst = update_thirst(thirst, time_since_last_played)
		
		if(pos_z):
			var cat_loc = Vector3(pos_x, pos_y, pos_z)
#			cat.set_translation(cat_loc)
		get_node("Room/spatial_bowl_food/food").set_flag(0, food_in_bowl)
		get_node("Room/spatial_bowl_water/water").set_flag(0, water_in_bowl)
		updated = true
	
	time = time + delta
	elapsed_wait_time = elapsed_wait_time + delta
	elapsed_sleep_time = elapsed_sleep_time + delta
	elapsed_litter_time = elapsed_litter_time + delta
	if(hud == true):
		update_hud()
	#Sleeps first,
	#Litters second
	#Eats third
	#Wanders and sits elsewise
	if(energy < 0):
		sleep()
	elif stomach_full == true:
		go_to_bathroom()
		move_cat()
	elif(thirst > thirst_limit and bladder.size() < 3 and not sitting):
		if(water_bowl.get_node("water").get_flag(0)):
			get_water()
		move_cat()
	elif(hunger > hunger_limit and stomach.size() < 3 and not sitting):
		if(food_bowl.get_node("food").get_flag(0)):
			get_food()
		move_cat()
	else:
		energy = energy - delta
		wander()
		move_cat_wander()
	if (stomach.size() <= 3):
		hunger = delta + hunger
	if (bladder.size() <= 3):
		thirst = delta + thirst
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

func update_hunger(hunger, time_since):
	if(stomach.size() < 3):
		if(hunger_limit*2 <= time_since):
			if(get_node("Room/spatial_bowl_food/food").get_flag(0)):
				get_node("Room/spatial_bowl_food/food").set_flag(0, false)
				hunger = 0
		elif(hunger_limit <= time_since):
			get_node("Room/spatial_bowl_food/food").set_flag(0, false)
			hunger = 50
		else:
			hunger = hunger - time_since
	return hunger

func update_thirst(hunger, time_since):
	if(stomach.size() < 3):
		if(thirst_limit*2 <= time_since):
			if(get_node("Room/spatial_bowl_water/water").get_flag(0)):
				get_node("Room/spatial_bowl_water/water").set_flag(0, false)
				thirst = 0
		elif(hunger_limit <= time_since):
			get_node("Room/spatial_bowl_water/water").set_flag(0, false)
			thirst = 50
		else:
			thirst = thirst - time_since
	return thirst

func update_digestion(digest, time_since):
	for i in range(0, digest.size() -1):
		if(digest[i] < time_since):
			digest[i]

func update_stat(stat, time_since, stat_max):
#	while time_since > 0:
#		if time_since > stat_max:
#			if(stat <= 0):
#				energy = stat_max
#				time_since = time_since - energy
#			elif time_since >= energy:
#				energy = 0
#				time_since = time_since - energy
#		else:
#			energy = energy - time_since
#			time_since = 0
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
		elapsed_sleep_time = 0
		sleep = rand_range(4000, 5000)
		anim.play("sleep")
	else:
		if(elapsed_sleep_time > sleep):
			sleeping = false
			energy = sleep_max
			

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
		wait = rand_range(1, 2)
		elapsed_wait_time = 0
		sitting = true
	elif(sitting == true and wait < elapsed_wait_time):
		sitting = false
		_update_path()
		
func get_food():
	if end != get_closest_point(get_node("Room/spatial_bowl_food").get_translation()):
#For food and water, investigate whether or not I need to change the following line:
#I believe it should use the get_flag method.
		if(get_node("Room/spatial_bowl_food/food") != null):
			arrive = false
			end = get_closest_point(get_node("Room/spatial_bowl_food").get_translation())
			_update_path()
		else:
			print("ASD:LFKJSD:LFKJ")
	if(arrive == true):
		arrive = false
		eat()

func get_water():
	if end != get_closest_point(get_node("Room/spatial_bowl_water").get_translation()):
		if(get_node("Room/spatial_bowl_food/food") != null):
			arrive = false
			end = get_closest_point(get_node("Room/spatial_bowl_water").get_translation())
			_update_path()
		else:
			print("ASD:LFKJSD:LFKJ")
	if(arrive == true):
		arrive = false
		drink_water()

#Use signal to trigger something after animation ends?
func eat():
	cat.get_node("Spatial/AnimationPlayer").get_animation("walk").set_loop(false)
	if(not cat.get_node("Spatial/AnimationPlayer").is_playing() and not eating ):
		anim.play("eat")
		eating = true
	elif(eating == true):
		if(not cat.get_node("Spatial/AnimationPlayer").is_playing()):
			get_node("Room/spatial_bowl_food/food").set_flag(0, false)
			eating = false
			wander()
			_update_path()
			hunger = 0
			digest_food()

func drink_water():
	cat.get_node("Spatial/AnimationPlayer").get_animation("walk").set_loop(false)
	if(not cat.get_node("Spatial/AnimationPlayer").is_playing() and not drinking ):
		anim.play("eat")
		drinking = true
	elif(drinking == true):
		if(not cat.get_node("Spatial/AnimationPlayer").is_playing()):
			get_node("Room/spatial_bowl_water/water").set_flag(0, false)
			drinking = false
			wander()
			_update_path()
			thirst = 0
			digest_water()

func digest_food():
	randomize()
	stomach.append(rand_range(100,100))
	
func digest_water():
	randomize()
	bladder.append(rand_range(100,100))
	
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
		elapsed_litter_time = elapsed_litter_time,
		litter = litter,
		stomach_full = stomach_full,
		food_in_bowl = get_node("Room/spatial_bowl_food/food").get_flag(0),
		water_in_bowl = get_node("Room/spatial_bowl_water/water").get_flag(0),
		previous_time = OS.get_unix_time(),
		pos_x = cat.get_translation().x,
		pos_y = cat.get_translation().y,
		pos_z = cat.get_translation().z
	}
	return savedict

func _ready():
	cat = get_node("../cat")
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

