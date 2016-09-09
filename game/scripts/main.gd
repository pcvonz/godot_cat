
extends Spatial



export var boids = 0
var open = false
var obs

func _ready():
	for i in range(0, boids):
		var temp = get_node("cat").duplicate()
		add_child(temp)
	obs = get_node("Observer")
	get_node("entry_door/door/col/col").connect("input_event", self, "toggle_anim", [get_node("entry_door")])
	get_node("closet_door 2/door/col/col").connect("input_event", self, "toggle_anim", [get_node("closet_door 2")])
	get_node("valentine/tty/col").connect("input_event", self, "toggle_anim", [get_node("valentine")])
	get_node("small lamp/lamp/col").connect("input_event", self, "toggle_light", [get_node("small lamp")])
	get_node("tall_lamp/lamp/col").connect("input_event", self, "toggle_light", [get_node("tall_lamp")])
	get_node("small lamp1/lamp/col").connect("input_event", self, "toggle_light", [get_node("small lamp1")])
	load_game()

func _notification(what):
	if(what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
		save_game()
		get_tree().quit()

func save_game():
    var savegame = File.new()
    savegame.open("user://savegame.save", File.WRITE)
    var savenodes = get_tree().get_nodes_in_group("Persist")
    for i in savenodes:
        var nodedata = i.save()
        savegame.store_line(nodedata.to_json())
    savegame.close()

func load_game():
	var savegame = File.new()
	if !savegame.file_exists("user://savegame.save"):
		return #Error!  We don't have a save to load

    # We need to revert the game state so we're not cloning objects during loading.  This will vary wildly depending on the needs of a project, so take care with this step.
    # For our example, we will accomplish this by deleting savable objects.
	var savenodes = get_tree().get_nodes_in_group("Persist")
#    for i in savenodes:
#        i.queue_free()
	# Load the file line by line and process that dictionary to restore the object it represents
	var currentline = {} # dict.parse_json() requires a declared dict.
	savegame.open("user://savegame.save", File.READ)
	while (!savegame.eof_reached()):
		currentline.parse_json(savegame.get_line())
		# First we need to create the object and add it to the tree and set its position.
#        var newobject = load(currentline["filename"]).instance()
#        get_node(currentline["parent"]).add_child(newobject)
#        newobject.set_pos(Vector2(currentline["posx"],currentline["posy"]))
		# Now we set the remaining variables.
		for i in currentline.keys():
			if (i == "filename" or i == "parent" or i == "posx" or i == "posy"):
				continue
			get_node("Navigation").set(i, currentline[i])
			print(i, ": ", currentline[i])
	savegame.close()
	
func toggle_anim(camera, event, click_pos, click_normal, shape_idx, object):
	var anim = object.get_node("AnimationPlayer")
	var dist = object.get_translation()
	dist = dist.distance_to(obs.get_translation())
	var anim = object.get_node("AnimationPlayer")
	if(event.is_action_pressed("interact") and dist < 4):
		if(anim.get_current_animation_pos() == 0):
			anim.play("default")
		else:
			anim.play_backwards()

func toggle_light( camera, event, click_pos, click_normal, shape_idx, object):
	var light = object.get_node("light")
	var dist = object.get_translation()
	dist = dist.distance_to(obs.get_translation())
	if(event.is_action_pressed("interact") and dist < 4):
		print(event)
		print(shape_idx)
		if(light.is_enabled()):
			light.set_enabled(false)
		else:
			light.set_enabled(true)