
extends Navigation

# member variables here, example:
# var a=2
# var b="textvar"
var path = []
var begin = Vector3()
var end = Vector3()
var cat
var count = 0
func _process(delta):
	if (path.size()>0):
		count+= 1
		if(cat.get_translation().distance_to(path[path.size()-1]) > 2):
			cat.seek_point = path[path.size()-1]
		else:
#			print(path[path.size()-1])
			path.remove(path.size()-1)
	else:
		idle()
		_update_path()

func _update_path():
	cat.get_node("Spatial/AnimationPlayer").get_animation("default").set_loop(true)
	cat.get_node("Spatial/AnimationPlayer").play("default")
	begin = get_closest_point(cat.get_translation())
	var p = get_simple_path(begin, end, true)
	path=Array(p)
	path.invert()
	set_process(true)

func _input(ev):
	if (ev.type==InputEvent.MOUSE_BUTTON and ev.button_index==BUTTON_LEFT and ev.pressed):
#		var from = get_node("../Observer/Spatial/Camera").project_ray_origin(ev.pos)
#		var to = from+get_node("../Observer/Spatial/Camera").project_ray_normal(ev.pos)*100
#		end = get_closest_point_to_segment(from,to)
#		get_node("targ").set_global_transform(Transform(get_node("targ").get_global_transform().basis, end))
		idle()
#		print(get_node("Room/nav").get_global_transform().basis)
		_update_path()

func idle():
	var nav_points = get_node("Room/nav_empty").get_children()
	randomize()
	end = get_closest_point(nav_points[rand_range(0, nav_points.size() - 1)].get_translation())
	print("END ", end)
		

func _ready():
	cat= get_node("../cat")
	set_process_input(true)

