extends Node2D
class_name ghost

const SPEED = 4.0

var dests
var path : PoolVector2Array
var next_tile_dist : float
var scatter_corner : Vector2

onready var map : astar_tile = $".."
onready var target_marker = $"target"
onready var sprite = $"sprite"
onready var player : player = $"../player"

func _ready():
	path = []
	next_tile_dist = 1.0
	yield(map, "ready")
	dests = map.path_cells
	path.append(dests[randi() % dests.size()])
	position = map.map_to_world(path[0])

func pathfind():
	return dests[randi() % dests.size()]

func go(delta : float):
	if map.scatter and path[-1] != scatter_corner:
		var old_next
		if path.size() > 1:
			old_next = path[1]
		path = map.get_point_path(path[0], scatter_corner)
		if path.size() == 1:
			return
		if path[1] != old_next:
			path = PoolVector2Array([path[0], old_next]) + path
		
	var step : float = SPEED * delta
	while step > 0 and path.size() > 1:
		if next_tile_dist < step:
			step -= next_tile_dist
			next_tile_dist = 1.0
			path.remove(0)
			if not map.scatter: # map.neighbors(path[0]).size() > 2 and 
				path = map.get_point_path(path[0], pathfind())
		else:
			next_tile_dist -= step
			step = 0
	if path.size() == 1 and not map.scatter:
		var curr = path[0]
		for i in range(5):
			path = map.get_point_path(path[0], pathfind())
			if path.size() > 0:
				break
			path.append(curr)
	update_pos()

func update_pos():
	if path.size() == 1:
		position = map.map_to_world(path[0])
	else:
		var a = map.map_to_world(path[0])
		var b = map.map_to_world(path[1])
		position = lerp(a, b, 1 - next_tile_dist)
	position += map.cell_size / 2
	
	target_marker.position = -position
	target_marker.position += map.map_to_world(path[-1]) + map.cell_size / 2

func _process(delta: float):
	go(delta)
