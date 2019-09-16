extends Node2D


func _ready():
	$Area2D.connect("body_entered", self, "on_collide")


func on_collide(body):
	if body.has_method("victoryCondition"):
		MusicPlayer.stop()
		MusicPlayer.stream = load("res://Music/DOS-88/Smooth Sailing.ogg")
		MusicPlayer.volume_db = 0
		MusicPlayer.play()
		body.victoryCondition()
