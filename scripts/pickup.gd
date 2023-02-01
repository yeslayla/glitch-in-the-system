extends Node2D

func _ready():
	var tile_map = get_node("%tile_map") as TileMap
	var tile_pos = tile_map.local_to_map(position)
	if(tile_map.get_cell(0, Vector2i(tile_pos.x, tile_pos.y)) != 0):
		queue_free()
