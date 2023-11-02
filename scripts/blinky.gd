extends ghost
class_name blinky

func _ready():
	yield(map, "ready")
	target_marker.modulate = Color(1,0,0)
	sprite.modulate = Color(1,0,0)
	scatter_corner = map.closest_path(Vector2(999, -999))

func pathfind():
	if player.ntile:
		return player.ntile
	if player.ctile:
		return player.ctile
	return self.dests[randi() % dests.size()]
