extends Node2D

@export
var HP: int = 8

@export
var color_str: String = "ffff00"

func _ready():
	var tile_map: TileMap = get_node("%tile_map")
	var tile_pos = tile_map.local_to_map(Vector2i(int(position.x), int(position.y)))
	if(tile_map.get_cell_source_id(0, tile_pos) != -1):
		push_error("Enemy placed at tile in use, freeing!")
		queue_free()

func take_damage(dmg):
	playAudio("Bomb_Drop.wav")
	modulate = Color(255,0,0)
	$CharacterBody2D/PointLight2D.color = Color(255,0,0)
	HP -= dmg
	reset_color()


var color_timer
func reset_color():
	if !color_timer:
		color_timer = Timer.new()
		add_child(color_timer)
		color_timer.connect("timeout",Callable(self,"color_timeout"))
	color_timer.start(0.125)

func color_timeout():
	var color = Color.from_string(color_str, Color.WHITE)
	modulate = color
	$CharacterBody2D/PointLight2D.color = Color(color)

func _process(_delta: float) -> void:
	if(HP <= 0):
		queue_free()


var audioPlayer
func playAudio(track):
	if !audioPlayer:
		audioPlayer = AudioStreamPlayer.new()
		get_parent().add_child(audioPlayer)
	audioPlayer.stream = load("res://assets/sound/%s" % track)
	audioPlayer.volume_db = -30
	audioPlayer.play()
