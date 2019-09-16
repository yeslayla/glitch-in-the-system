extends Node2D

export var HP = 8
export var color = "ffff00"

func _ready():
	pass 
	
func take_damage(dmg):
	playAudio("Bomb_Drop.wav")
	modulate = Color(255,0,0)
	$KinematicBody2D/Light2D.color = Color(255,0,0)
	HP -= dmg
	reset_color()


var color_timer
func reset_color():
	if !color_timer:
		color_timer = Timer.new()
		add_child(color_timer)
		color_timer.connect("timeout", self, "color_timeout")
	color_timer.start(0.125)
	
func color_timeout():
	modulate = Color(color)
	$KinematicBody2D/Light2D.color = Color(color)

func _process(delta):
	if(HP <= 0):
		queue_free()


var audioPlayer	
func playAudio(track):
	if !audioPlayer:
		audioPlayer = AudioStreamPlayer.new()
		get_parent().add_child(audioPlayer)
	audioPlayer.stream = load("res://Sound/" + track)
	audioPlayer.volume_db = -30
	audioPlayer.play()