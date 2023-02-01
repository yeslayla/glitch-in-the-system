class_name EquipmentSaber
extends Equipment

@export
var animation_player: AnimationPlayer

@export
var area: Area2D

@export
var damage: int = 1

func _ready() -> void:
	self.init_equipment()

	self.area.body_entered.connect(self._on_body_entered)
	self._update_z_index()

func _process(delta: float) -> void:
	self.process_equipment(delta)

	if self.is_sheathed():
		if self.animation_player.current_animation != "sheathed":
			self.animation_player.play("sheathed")
	else:
		if not self.animation_player.current_animation in ["attack", "idle"]:
			self.animation_player.play("idle")
		if Input.is_action_just_pressed("attack"):
			self.animation_player.play("attack")

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(self.damage)
