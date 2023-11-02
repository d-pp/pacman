extends ghost
class_name inky

onready var blinky : blinky = $"../blinky"

func _ready():
	yield(map, "ready")
	target_marker.modulate = Color(0,0,1)
	sprite.modulate = Color(0,0,1)
	scatter_corner = map.closest_path(Vector2(999, 999))

func pathfind():
	var p_tile
	
	if player.ntile:
		p_tile = ahead(player.ntile)
	elif player.ctile:
		p_tile = ahead(player.ctile)
	else:
		p_tile = self.dests[randi() % dests.size()]
	
	var b_tile
	if blinky.path.size() == 1:
		b_tile = blinky.path[0]
	else:
		b_tile = blinky.path[1]
	
	var target = b_tile + (p_tile - b_tile) * 2
	return map.closest_path(target)

func ahead(cell : Vector2):
	return cell + player.currdir * 3
