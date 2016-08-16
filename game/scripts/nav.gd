
extends Navigation

# member variables here, example:
# var a=2
# var b="textvar"
var path = []
var begin = Vector3()
var end = Vector3()
var cat
func _process(delta):
	if (path.size()>1):
		print(cat.get_translation().distance_to(path[path.size()-1]))
		if(cat.get_translation().distance_to(path[path.size()-1]) > .1):
			cat.seek_point = path.size()-1
		else:
			path.remove(path.size()-1)

func _update_path():
	end = get_node("targ").get_collision_point()
	begin = get_closest_point(cat.get_translation())
	
#	print(end)
	print(begin)
	var p = get_simple_path(begin, end, true)
	path=Array(p)
	path.invert()
	print(path)
	set_process(true)

func _ready():
	cat= get_node("../cat")
	_update_path()

