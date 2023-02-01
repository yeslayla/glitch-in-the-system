extends Camera2D

var speed = 2

func _process(_delta: float) -> void:
	var camera_move_dir = Vector2(0,0)
	if(Input.is_action_pressed("right")):
		camera_move_dir += Vector2(speed,0)
	if(Input.is_action_pressed("left")):
		camera_move_dir -= Vector2(speed,0)

	if(Input.is_action_pressed("up")):
		camera_move_dir -= Vector2(0,speed)
	if(Input.is_action_pressed("down")):
		camera_move_dir += Vector2(0,speed)

	global_translate(camera_move_dir)
