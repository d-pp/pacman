extends TileMap
class_name astar_tile

const NEIGHBORS = [Vector2(0,-1), Vector2(0,1), Vector2(-1,0), Vector2(1,0)]

const id_offset = 2048

onready var score = $"../score"
const pellet_score = 10

var _astar = AStar2D.new()
var path_cells = []
var scatter = false
var scatter_time = 0
const SCATTER_DURATION = 5.0

func _ready():
	seed(OS.get_system_time_msecs())
	_get_and_connect_points()

func _process(delta):
	if scatter:
		if scatter_time > 0:
			scatter_time -= delta
		else:
			scatter = false

func _get_and_connect_points():
	var cells = get_used_cells()
	for cell in cells:
		if is_path(cell):
			path_cells.append(cell)
			_astar.add_point(id(cell), cell)
	for cell in path_cells:
		for n in NEIGHBORS:
			var n_cell = cell + n
			if path_cells.has(n_cell):
				_astar.connect_points(id(cell), id(n_cell), false)

func is_path(cell : Vector2):
	return get_cellv(cell) == 0

func closest_path(cell : Vector2):
	if is_path(cell):
		return cell
	var closest = Vector2(999999999999, 999999999999)
	for p_cell in path_cells:
		if p_cell.distance_squared_to(cell) < closest.distance_squared_to(cell):
			closest = p_cell
	if not is_path(closest):
		return path_cells[randi() % path_cells.size()]
	return closest

func neighbors(cell : Vector2):
	var neighbors = []
	for n in NEIGHBORS:
		var n_cell = cell + n
		if is_path(n_cell):
			neighbors.append(n_cell)
	return neighbors
		

func eat(cell : Vector2):
	match get_cell_autotile_coord(cell.x, cell.y):
		Vector2(0,0):
			return
		Vector2(2,0):
			scatter = true
			scatter_time = SCATTER_DURATION
		_:
			score.add(pellet_score)
	set_cell(cell.x, cell.y, 0, false, false, false, Vector2(0, 0))

func get_point_path(start, end):
	return _astar.get_point_path(id(start), id(end))

func id(point : Vector2):
	var a = point.x + id_offset
	var b = point.y + id_offset
	# cantor pairing function
	return b + (a + b) * (a + b + 1) / 2

func invert_id(z : int):
	var w = floor((sqrt(8 * z + 1) - 1) / 2)
	var t = (w*w + w) / 2
	var y = z - t
	return Vector2(w - y - id_offset, y - id_offset)
	
