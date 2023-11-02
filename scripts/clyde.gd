extends ghost
class_name clyde

func _ready():
	yield(map, "ready")
	target_marker.modulate = Color(2,0.5,0)
	sprite.modulate = Color(2,0.5,0)
	scatter_corner = map.closest_path(Vector2(-999, 999))

func pathfind():
	var p_tile
	if player.ntile:
		p_tile = player.ntile
	elif player.ctile:
		p_tile = player.ctile
	else:
		return self.dests[randi() % dests.size()]
	if path[0].distance_to(p_tile) < 8:
		return scatter_corner
	return p_tile
