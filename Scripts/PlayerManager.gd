extends KinematicBody2D




#----------- Equipment
var currentlyEquiped = "none"
var sheathed = "saber"


#----------- misc movement
const UP = Vector2(0, -1)
const BASE_GRAVITY = 20
const BASE_SPEED = 150
var motion = Vector2()

#----------- Jumping related variables
const BASE_JUMP = -250 #Motion added for a jump
var extra_jumps = 0 #Number of double jumps a player has
var current_jumps = 0 #Number of jumps a player has left
var jumpHeight = 0
var coins = 0
var GAMEOVER = false

const JUMP_PLATFORM = preload("res://Nodes/jump_platform.tscn")

func _ready():
	extra_jumps = SaveManager.get_action_value('jump')/4
	jumpHeight = SaveManager.get_action_value('jump') * -2
	sheathed = SaveManager.get_equiped()
	updateEquipment()
	
func victoryCondition():
	SaveManager.change_upgrade_points(coins)
	slide_out()
	

const VICTORY_SCREEN = "res://Nodes/Victory.tscn"
var slide_progress = 0
var slide_timer
const SLIDE_SPEED = 0.0125
const PIXELS_PER = 32
func slide_out():
	$CanvasLayer/GUI/SlideRect.rect_size.y = slide_progress
	if slide_progress < 600:
		slide_progress += PIXELS_PER
		if(!slide_timer):
			slide_timer = Timer.new()
			add_child(slide_timer)
			slide_timer.connect("timeout", self, "slide_out")
		slide_timer.start(SLIDE_SPEED)
	else:
		get_tree().change_scene(VICTORY_SCREEN)
		
func done_sliding():
	return slide_progress >= 600
	
signal unequip
	
var waitingToUpdate = 0
func _process(delta):
	if(Input.is_action_just_pressed("sheath")):
		switch_sheath()
	if(Input.is_action_pressed("attack") and currentlyEquiped == "none"):
		switch_sheath()
			
func deal_damage(dmg = 1):
	playAudio("Hero_Hurt.wav")
	updateHealth(-dmg)
	print(getHealth())
		
func switch_sheath():
		if(sheathed == "none"):
			sheathed = currentlyEquiped
			currentlyEquiped = "none"
		else:
			currentlyEquiped = sheathed
			sheathed = "none"
		emit_signal("unequip")
		updateEquipment()
	
var audioPlayer	
func playAudio(track):
	if !audioPlayer:
		audioPlayer = AudioStreamPlayer.new()
		self.add_child(audioPlayer)
	audioPlayer.stream = load("res://Sound/" + track)
	audioPlayer.volume_db = -30
	audioPlayer.play()
		
func pickupCoin():
	coins += 1
	$CanvasLayer/GUI/Label.text = String(coins)
	
var maxHP = 25
var health
func updateHealth(val):
	if !health:
		health = maxHP
		$CanvasLayer/GUI/Healthbar.max_value = maxHP
	health += val
	$CanvasLayer/GUI/Healthbar.value = health
	if(health <= 0):
		game_over()
	
func getHealth():
	if !health:
		health = maxHP
	return health
	
func game_over():
	GAMEOVER = true
	$CanvasLayer/GUI.hide()
	$CanvasLayer/GameOver.show()
	
var tileMap
		
func _physics_process(delta):
	if GAMEOVER:
		hide()
	else:
		#Implement the force of gravity!
		motion.y += BASE_GRAVITY
		
		#Moves the player left & right
		if(Input.is_action_pressed("right")):
			motion.x = BASE_SPEED
		elif (Input.is_action_pressed("left")):
			motion.x = -BASE_SPEED
		else:
			motion.x = 0
	
		if is_on_floor():
			motion.y = 0
	
		if !tileMap:
			var childs = get_parent().get_children()
			for child in childs:
				if typeof(child) == typeof(TileMap):
					tileMap = child
					break
	
		#Handle the jumpings
		if (Input.is_action_just_pressed("up")):
			if is_on_floor():
				if(Input.is_action_pressed("down")):
					var tilePos = tileMap.world_to_map(position)
					tilePos.y += 1
					if(tileMap.get_cell(tilePos.x, tilePos.y) == 1):
						position.y += 4
				else:
					motion.y = BASE_JUMP + jumpHeight
					#Reset number of jumps
					current_jumps = extra_jumps
			elif current_jumps > 0:
				motion.y = BASE_JUMP + jumpHeight
				playAudio("Sword.wav")
				spawn_jump_platform()
				current_jumps -= 1
	
	
		#Do animations
		$AnimatedSprite.flip_h = get_global_mouse_position().x < position.x
		
		if is_on_floor():
			if($AnimatedSprite.animation == "jump"):
				playAudio("Sword2.wav")
			if abs(motion.x) > 0:
				if(motion.x > 0):
					$AnimatedSprite.play("walk", true)
				else:
					$AnimatedSprite.play("walk", false)
			else:
				$AnimatedSprite.play("idle")
		else:
			$AnimatedSprite.play("jump")
		
		motion = move_and_slide(motion, UP)

func spawn_jump_platform():	
	var platform = JUMP_PLATFORM.instance()
	get_parent().add_child(platform)
	platform.position = Vector2(position.x, position.y + 4)
	
	pass

func updateEquipment():
	var equipmentNode = get_child(3)
	if(equipmentNode.get_children().size() + 1 > 0):
		for enode in equipmentNode.get_children():
			enode.queue_free()
	var equipment = load("res://Nodes/Equipment/" + currentlyEquiped + ".tscn").instance()
	equipmentNode.add_child(equipment)
