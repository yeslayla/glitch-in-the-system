extends CharacterBody2D

const UP = Vector2(0, -1)
const BASE_GRAVITY = 20

@export var active_distance = 32
@export var angry_distance = 100

@export var speed = 25

@export var attack_speed = 1

var angry = false

var knockback = 0
var player

const UPDATE_ANGRY_TIME = 0.25

var motion = Vector2(0, 0)
var TIMER

func _ready():
	$AnimatedSprite2D.play("default")
	$Area2D.connect("body_entered",Callable(self,"collision_method"))
	var alarmRoot = get_parent().get_parent()
	if alarmRoot.has_node("BaddieAlarm"):
		for node in alarmRoot.get_children():
			if node.name == "BaddieAlarm":
				node.timeout.connect(self.update_angry)
				TIMER = node
				break
	else:
		var node := Timer.new()
		node.name = "BaddieAlarm"
		node.timeout.connect(self.update_angry)
		alarmRoot.add_child.call_deferred(node)
		node.start.call_deferred(UPDATE_ANGRY_TIME)
		TIMER = node

func collision_method(body):
	if body.has_method("deal_damage"):
		body.deal_damage()
		knockback += 100

func take_damage(dmg):
	knockback += 25 * dmg
	get_parent().take_damage(dmg)

func update_angry():
	if angry && global_position.distance_to(player.global_position) > angry_distance:
		angry = false
	elif global_position.distance_to(player.global_position) < active_distance:
		angry = true
	if(TIMER.wait_time <= 0):
		TIMER.start(UPDATE_ANGRY_TIME)


func _physics_process(_delta: float) -> void:
	#Implement the force of gravity!
	motion.y += BASE_GRAVITY

	if is_on_floor():
		motion.y = 0

	if knockback > 0:
		motion.y -= knockback/2
		if(player.global_position.x > global_position.x):
			motion.x -= knockback
		else:
			motion.x += knockback
		knockback -= 30
	else:
		if !player:
			player = get_node("/root/World3D/Player")
		else:


			if angry:
				angry = true
				if($AnimatedSprite2D.animation != "run"):
					$AnimatedSprite2D.play("run")
				if player.global_position.distance_to(global_position) > 24:
					if(player.global_position.x > global_position.x):
						motion.x += speed
						$AnimatedSprite2D.flip_h = false
						$Area2D.rotation = 0
					else:
						motion.x -= speed
						$AnimatedSprite2D.flip_h = true
						$Area2D.rotation = PI
				else:
					knockback += 60
			else:
				$AnimatedSprite2D.play("default")

	set_velocity(motion)
	set_up_direction(UP)
	move_and_slide()
	motion = velocity
