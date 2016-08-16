
extends Navigation

# member variables here, example:
# var a=2
# var b="textvar"
var path = []
var begin = Vector3()
var end = Vector3()
var cat
func _process(delta):
	if (path.size()>0):
		print(cat.get_translation().distance_to(path[path.size()-1]) < .1)
		if(cat.get_translation().distance_to(path[path.size()-1]) > .5):
			cat.seek_point = path[path.size()-1]
			print("SEEKING THIS POINT: ", cat.seek_point)
		else:
			print("ARRIVE: ", path)
			path.remove(path.size()-1)

func _update_path():
	
	begin = get_closest_point(cat.get_translation())
#	print(end)
	var p = get_simple_path(begin, end, true)
	print(end)
	print(begin)

	path=Array(p)
	print(path)
	path.invert()
	set_process(true)

func _input(ev):
	if (ev.type==InputEvent.MOUSE_BUTTON and ev.button_index==BUTTON_LEFT and ev.pressed):
		var from = get_node("../Observer/Spatial/Camera").project_ray_origin(ev.pos)
		var to = from+get_node("../Observer/Spatial/Camera").project_ray_normal(ev.pos)*100
		end = get_closest_point_to_segment(from,to)
		get_node("targ").set_global_transform(Transform(get_node("targ").get_global_transform().basis, end))
		_update_path()

func _ready():
	cat= get_node("../cat")
	set_process_input(true)

