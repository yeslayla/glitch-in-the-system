extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
const DASH_SPEED = 300
const UP = Vector2(0, -1)
const RADperDEGREE = 57.2957795

const SLASH_ANIMATION = preload("res://Nodes/Animations/SlashAnimation.tscn")
var player
var colliderShape


func _ready():
	colliderShape = $AnimatedSprite/Area2D/CollisionShape2D.get_shape()
	get_child(0).get_child(0).hide()
	player = get_parent().get_parent()
	player.connect("unequip", self, "on_unequip")
	$AnimatedSprite.connect("animation_finished", self, "on_animation_finished")
	$AnimatedSprite/Area2D.connect("body_entered", self, "on_collide")
	$AnimatedSprite.play("Spawn")
	pass # Replace with function body.

var audioPlayer	
func playAudio(track):
	if !audioPlayer:
		audioPlayer = AudioStreamPlayer.new()
		self.add_child(audioPlayer)
	audioPlayer.stream = load("res://Sound/" + track)
	audioPlayer.volume_db = -30
	audioPlayer.play()

func on_unequip():
	$AnimatedSprite.play("Spawn", true)

func on_collide(body):
	if(body.has_method("take_damage")):
		print(body)
		if($AnimatedSprite.animation == "Attack"):
			print("ATTACK")
			body.take_damage(1)
	pass


var pos
func _physics_process(delta):
	
	$AnimatedSprite.flip_h = get_global_mouse_position().x < global_position.x
	if(get_global_mouse_position().x < global_position.x):
		$AnimatedSprite/Area2D.rotation = PI
	else:
		$AnimatedSprite/Area2D.rotation = 0
	
	if($AnimatedSprite.animation == "Attack"):
		$AnimatedSprite/Area2D/CollisionShape2D.shape = colliderShape
	else:
		$AnimatedSprite/Area2D/CollisionShape2D.shape = null
		
	if($AnimatedSprite.animation != "Spawn"):
		if(Input.is_action_just_pressed("attack")):
			if($AnimatedSprite.animation != "Attack"):
				playAudio("Charge2.wav")
			get_child(0).get_child(0).show()
			$AnimatedSprite.play("Attack")
			pos = player.global_position - get_global_mouse_position()
			var angle = atan(pos.y/pos.x)
			var goUp = -1
			var goRight = -1
			if(pos.y < 0):
				goUp = 1
			if(pos.x < 0):
				goRight = 1
			var xVar = cos(abs(angle)) * DASH_SPEED * goRight
			var yVar = sin(abs(angle)) * DASH_SPEED
			yVar = (yVar) * goUp - 20
			pos = Vector2(xVar, yVar)
			
	if($AnimatedSprite.animation == "Attack"):
		player.move_and_slide(pos, UP)



	
func on_animation_finished():
	if($AnimatedSprite.animation != "idle"):
		get_child(0).get_child(0).hide()
		$AnimatedSprite.play("idle")
