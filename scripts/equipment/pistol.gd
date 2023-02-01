class_name EquipmentGun
extends Equipment

@export
var bullet: PackedScene

@export
var left_arm: Line2D

@export
var right_arm: Line2D

@export
var origin: Node2D

@export
var bullet_spawning_point: Node2D

@export
var pistol_handle: Node2D

@export
var sprite: Sprite2D

@export
var sheath_point: Node2D

@onready
var _original_sprite_pos: Vector2 = sprite.position

@onready
var _original_sprite_rotation: float = sprite.rotation

func _ready() -> void:
	self.init_equipment()

	self.sheath.connect(self._on_sheath)
	self._on_sheath(self.is_sheathed())

func _process(delta: float) -> void:
	self.process_equipment(delta)

	if self.is_sheathed():
		return

	self.origin.look_at(self.get_global_mouse_position())

	self.right_arm.clear_points()
	self.right_arm.add_point(Vector2(2.5, 0))
	self.right_arm.add_point(to_local(self.pistol_handle.global_position))
	self.left_arm.clear_points()
	self.left_arm.add_point(Vector2(-2.5, 0))
	self.left_arm.add_point(to_local(self.pistol_handle.global_position))

	self.sprite.flip_v = self.is_facing_left()

	if Input.is_action_just_pressed("attack"):
		var projectile: Node2D = self.bullet.instantiate()
		self.get_parent().get_parent().add_child(projectile)
		projectile.global_position = self.bullet_spawning_point.global_position
		projectile.rotation = origin.rotation

func _on_sheath(sheathed: bool):
	self.auto_flip = sheathed

	if sheathed:
		self.origin.rotation = 0
		self.sprite.position = self.sheath_point.position
		self.sprite.rotation = self.sheath_point.rotation

		self.right_arm.clear_points()
		self.left_arm.clear_points()
	else:
		self.sprite.position = self._original_sprite_pos
		self.sprite.rotation = self._original_sprite_rotation


