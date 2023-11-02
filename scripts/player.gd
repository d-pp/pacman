extends Node2D
class_name player

const dir = {
	STOP = Vector2(0, 0),
	UP = Vector2(0, -1),
	DOWN = Vector2(0, 1),
	LEFT = Vector2(-1, 0),
	RIGHT = Vector2(1, 0)
}

const SPEED = 4.0

const default_screen = Vector2(900, 900)
const title_bar_h = 30

onready var map = $".."
onready var sprite = $AnimatedSprite

var currdir = dir.STOP
var nextdir = dir.STOP
var ctile
var ntile
var ntile_dist = 1.0

func _ready() -> void:
	var size = OS.get_screen_size()
	OS.set_window_position(Vector2((size.x-default_screen.x)/2, (size.y-default_screen.y)/2-title_bar_h))
	OS.set_window_size(default_screen)
	yield(map, "ready")
	ctile = map.path_cells[randi() % map.path_cells.size()]
	map.eat(ctile)
	ntile = ctile

func controls():
	# case stopped
	if currdir == dir.STOP:
		if Input.is_action_just_pressed("ui_up"):
			currdir = dir.UP
		elif Input.is_action_just_pressed("ui_down"):
			currdir = dir.DOWN
		elif Input.is_action_just_pressed("ui_left"):
			currdir = dir.LEFT
		elif Input.is_action_just_pressed("ui_right"):
			currdir = dir.RIGHT
	# case moving
	if currdir == dir.UP or currdir == dir.DOWN:
		if Input.is_action_just_pressed("ui_left"):
			nextdir = dir.LEFT
		elif Input.is_action_just_pressed("ui_right"):
			nextdir = dir.RIGHT
	elif currdir == dir.LEFT or currdir == dir.RIGHT:
		if Input.is_action_just_pressed("ui_up"):
			nextdir = dir.UP
		elif Input.is_action_just_pressed("ui_down"):
			nextdir = dir.DOWN
	# turn around
	if currdir == dir.UP and Input.is_action_just_pressed("ui_down") or \
		currdir == dir.DOWN and Input.is_action_just_pressed("ui_up") or \
		currdir == dir.LEFT and Input.is_action_just_pressed("ui_right") or \
		currdir == dir.RIGHT and Input.is_action_just_pressed("ui_left"):
		flip_dir()
	
	if currdir == dir.STOP:
		if sprite.frame in [26,0,12,13]:
			sprite.animation = "stopped"
	else:
		sprite.animation = "moving"
	
	var animdir = currdir if nextdir == dir.STOP else nextdir
	
	if animdir == dir.STOP:
		sprite.rotation = 0
	elif animdir == dir.RIGHT:
		sprite.flip_h = false
		sprite.rotation = 0
	elif animdir == dir.DOWN:
		if sprite.flip_h:
			sprite.rotation = 1.8*PI
		else:
			sprite.rotation = 0.2*PI
	elif animdir == dir.LEFT:
		sprite.flip_h = true
		sprite.rotation = 0
	elif animdir == dir.UP:
		if sprite.flip_h:
			sprite.rotation = 0.2*PI
		else:
			sprite.rotation = 1.8*PI
	
	if Input.is_action_just_pressed("ui_cancel"):
		print("Pack-Man cannot stop")

func flip_dir():
	var tmp = ctile
	ctile = ntile
	ntile = tmp
	ntile_dist = 1 - ntile_dist
	currdir = -currdir
	nextdir = dir.STOP

func move(delta : float):
	if currdir == dir.STOP:
		return
	var step : float = delta * SPEED
	while step > 0:
		if ctile == ntile:
			map.eat(ctile)
			ntile = ctile + nextdir
			if ntile != ctile and map.is_path(ntile):
				currdir = nextdir
				nextdir = dir.STOP
				continue
			ntile = ctile + currdir
			if map.path_cells.has(ntile):
				continue
			ntile = ctile
			if currdir.y != 0:
				sprite.animation = "stopped"
			currdir = dir.STOP
			nextdir = dir.STOP
			return
		if ntile_dist < step:
			step -= ntile_dist
			ntile_dist = 1.0
			ctile = ntile
		else:
			ntile_dist -= step
			step = 0.0

func update_pos():
	var a = map.map_to_world(ctile)
	var b = map.map_to_world(ntile)
	position = lerp(b, a, ntile_dist)
	position += map.cell_size / 2

func _process(delta : float):
	if map.scatter:
		var time = OS.get_system_time_msecs()
		sprite.modulate = Color.from_hsv((time % 400) / 400.0, 1, 1)
	else:
		sprite.modulate = Color(1,1,1)
	if sprite.animation == "dying":
		if sprite.frame >= 9:
			OS.delay_msec(200)
			get_tree().reload_current_scene()
	else:
		controls()
		move(delta)
		update_pos()


func _on_Area2D_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if area.is_in_group("ghosts"):
		if map.scatter:
			print("headshot")
		else:
			currdir = dir.STOP
			nextdir = dir.STOP
			if sprite.flip_h:
				sprite.rotation = 0.6*PI
			else:
				sprite.rotation = 1.4*PI
			sprite.animation = "dying"
