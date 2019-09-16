extends AnimatedSprite

func _ready():
	play("spawn")
	connect("animation_finished", self, "on_animation_finished")


func on_animation_finished():
	if(animation == "spawn"):
		play("destroy")
	else:
		get_parent().queue_free()