class_name PlayerAnimationPlayer
extends AnimationPlayer

@export
var sprite: Sprite2D

func set_direction(dir: Vector2) -> void:
	self.sprite.flip_h = dir == Vector2.LEFT

func safe_play(animation: String) -> void:
	if self.current_animation != animation:
		self.play(animation)
