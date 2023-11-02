extends ghost
class_name pinky

func _ready():
	yield(map, "ready")
	target_marker.modulate = Color(2,0.5,0.5)
	sprite.modulate = Color(2,0.5,0.5)
	scatter_corner = map.closest_path(Vector2(-999, -999))

func pathfind():
	if player.ntile:
		return ahead(player.ntile)
	if player.ctile:
		return ahead(player.ctile)
	return self.dests[randi() % dests.size()]

func ahead(cell : Vector2):
	return map.closest_path(cell + player.currdir * 3)
