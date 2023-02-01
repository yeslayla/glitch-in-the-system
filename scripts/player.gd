class_name Player
extends CharacterBody2D

signal unequip()
signal coin_update(int)

signal health_update(int)
signal death()


const BASE_MOVEMENT_SPEED := 10000
const BASE_JUMP_HEIGHT := -250



@export
var jump_platform: PackedScene

@export
var animation_player: AnimationPlayer

@export
var arms_sprite: Sprite2D

@export
var damage_sound: AudioStream

@export
var sword_sound: AudioStream

@export_category("Combat")
@export
var max_hp: int = 25


@export_dir
var equipment_dir: String

@export
var equipment_node: Node2D

@export_category("Movement")
@export
var default_speed: float = 1

@export
var default_jump_height: float = 1


@onready
var health: int = max_hp :
	set(value):
		value = clampi(value, 0, max_hp)

		if value != health:
			health_update.emit(value)
		if value == 0:
			death.emit()
		health = value
	get:
		return health

@onready
var default_gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var coins: int = 0 :
	set(value):
		if value != coins:
			coin_update.emit(coins)
		coins = value
	get:
		return coins

var motion: Vector2 = Vector2.ZERO

var currently_equiped: String = "pistol"

var extra_jumps: int = 2

var current_jumps: int = 0

var jump_height: float = 0

func _ready() -> void:
	self.add_item("pistol")
	self.add_item("saber")

func deal_damage(dmg = 1) -> void:
	self._play_audio(damage_sound)
	self.health -= dmg

func switch_sheath() -> void:
	var item := get_currently_equiped_node()
	item.toggle_sheath()


func _play_audio(track: AudioStream) -> void:
	var audio_player = get_node_or_null("AudioStreamPlayer")
	if !audio_player:
		audio_player = AudioStreamPlayer.new()
		audio_player.name = "AudioStreamPlayer"
		self.add_child(audio_player)
	audio_player.stream = track
	audio_player.volume_db = -30
	audio_player.play()

func pickup_coin(coin_value: int = 1) -> void:
	self.coins += coin_value

func _process(_delta: float) -> void:
	var item = get_currently_equiped_node()
	arms_sprite.visible = (item == null || item.is_sheathed())

func _physics_process(delta: float) -> void:

	self._combat_process(delta)
	self._gravity_process(delta)
	self._movement_process(delta)
	self._animation_process(delta)

	self.set_velocity(self.motion)
	self.set_up_direction(Vector2.UP)
	self.move_and_slide()
	self.motion = self.velocity

func _combat_process(_delta: float) -> void:

	for i in range(0, 2):
		if Input.is_action_just_pressed("equip_slot_%s" % [str(i+1)]):
			if self.equipment_node.get_child_count() > i:
				self.equip(self.equipment_node.get_child(i).name)

	if Input.is_action_just_pressed("sheath"):
		self.switch_sheath()
	if Input.is_action_pressed("attack") and self.get_currently_equiped_node().is_sheathed():
		self.switch_sheath()

func _gravity_process(delta: float) -> void:
	self.motion.y += self.default_gravity * delta
	if self.is_on_floor():
		self.motion.y = 0

func _movement_process(delta: float) -> void:

	# Horizontal movement
	if Input.is_action_pressed("move_right"):
		self.motion.x = (self.BASE_MOVEMENT_SPEED * delta) * self.default_speed
	elif Input.is_action_pressed("move_left"):
		self.motion.x = (-self.BASE_MOVEMENT_SPEED * delta) * self.default_speed
	else:
		self.motion.x = 0

	# Handle jumps
	if Input.is_action_just_pressed("jump"):
		if self.is_on_floor():

			if Input.is_action_pressed("move_down"):
				pass # lmanley: todo reimplement platforms
			else:
				self.jump()
				self.current_jumps = self.extra_jumps

		elif self.current_jumps > 0:
			self.jump()
			self.spawn_jump_platform()
			self.current_jumps -= 1

func jump() -> void:
	self.motion.y = self.BASE_JUMP_HEIGHT * self.default_jump_height

func spawn_jump_platform() -> void:
	self._play_audio(sword_sound)
	var platform = self.jump_platform.instantiate()
	self.get_parent().add_child(platform)
	platform.position = Vector2(self.position.x, self.position.y + 4)

func _animation_process(_delta: float) -> void:

	if animation_player is PlayerAnimationPlayer:
		if get_global_mouse_position().x < global_position.x:
			self.animation_player.set_direction(Vector2.LEFT)
		else:
			self.animation_player.set_direction(Vector2.RIGHT)

		if not self.is_on_floor():
			self.animation_player.safe_play("jump")
		elif abs(self.motion.x) > 0:
			self.animation_player.safe_play("walk")
		else:
			self.animation_player.safe_play("idle")

func get_currently_equiped_node() -> Equipment:
	return self.equipment_node.get_node_or_null(self.currently_equiped)

func equip(equipment_id: String) -> void:
	if equipment_id == self.currently_equiped:
		self.switch_sheath()
	else:
		var current = self.get_currently_equiped_node()
		if not current.is_sheathed():
			current.toggle_sheath()

		currently_equiped = equipment_id
		current = self.get_currently_equiped_node()
		if current.is_sheathed():
			current.toggle_sheath()

func add_item(equiment_id: String) -> void:
	var item = load("%s/%s.tscn" % [equipment_dir, equiment_id]).instantiate()
	item.name = equiment_id
	equipment_node.add_child(item)
