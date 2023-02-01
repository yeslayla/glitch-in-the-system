class_name Projectile
extends Area2D

@export
var damage: int = 1

@export
var speed: float = 500

@export
var lifetime: float = 5

func _ready():
	self.body_entered.connect(self._on_body_entered)

	var timer: Timer = Timer.new()
	self.add_child(timer)
	timer.timeout.connect(func():
		self.queue_free()
	)
	timer.start(lifetime)

func _physics_process(delta: float) -> void:
	var direction = Vector2.from_angle(rotation)

	self.position += (speed*delta) * direction

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(self.damage)
	self.queue_free()
