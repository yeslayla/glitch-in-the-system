class_name Equipment
extends Node2D

signal sheath(bool)

@export
var auto_z_index: bool = true

@export
var auto_flip: bool = true

var _sheathed: bool = true

var _original_z_index: int

func init_equipment() -> void:
	self._original_z_index = self.z_index
	self._update_z_index()

func is_sheathed() -> bool:
	return self._sheathed

func toggle_sheath() -> void:
	self._sheathed = !self._sheathed

	self._update_z_index()

	self.sheath.emit(self._sheathed)

func _update_z_index() -> void:
	if self.auto_z_index:
		if self._sheathed:
			self.z_index = _original_z_index - 100
		else:
			self.z_index = _original_z_index

func is_facing_left() -> bool:
	return get_global_mouse_position().x < global_position.x

func process_equipment(_delta: float) -> void:
	self._update_z_index()

	if auto_flip:
		if self.is_facing_left():
			self.scale.x = -1
		else:
			self.scale.x = 1
	else:
		self.scale.x = 1
