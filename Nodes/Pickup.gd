extends Node2D

var tileMap
func _ready():
	var tileMap = get_node("/root/World/TileMap")
	var tilePos = tileMap.world_to_map(position)
	if(tileMap.get_cell(tilePos.x, tilePos.y) != 0):
		queue_free()