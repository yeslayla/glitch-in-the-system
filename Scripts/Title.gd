extends Control

var fadeTo

func _ready():
	MusicPlayer.stop()
	MusicPlayer.stream = load("res://Music/DOS-88/Race to Mars.ogg")
	MusicPlayer.volume_db = 0
	MusicPlayer.play()
	$Fader.modulate.a = 1
	$CreditsMenu.hide()
	
	$"New Game".connect("button_down", self, "new_game")
	$Credits.connect("button_down", self, "show_credits")
	$Quit.connect("button_down", self, "on_quit_down")
	
	fade_out(3, 1, -1) 
	
func new_game():
	SaveManager.add_run()
	fadeTo = "res://Nodes/Game.tscn"
	fade_out(3, -80)

func show_credits():
	$CreditsMenu.show()

func on_quit_down():
	get_tree().quit()
	

var timePassed = 0 #Current amount of time spend displaying te
const CHECK_LENGTH = 0.05 #Interval to check for updates
var timeNeeded = 0 #Time that it takes to display the text
var fadeTimer #Timer object

var multiplier = 1
var adder = 0
func fade_out(seconds, multi = 1, add = 0):
	multiplier = multi
	adder = add
	timeNeeded = seconds
	timePassed = 0
	if(!fadeTimer):
		fadeTimer = Timer.new()
		add_child(fadeTimer)
		fadeTimer.connect("timeout", self, "on_fade_timeout")
	fadeTimer.start(CHECK_LENGTH)

func on_fade_timeout():
	timePassed += CHECK_LENGTH
	MusicPlayer.volume_db = multiplier * (timePassed/timeNeeded)
	$Fader.modulate.a = abs(timePassed/timeNeeded + adder)
	if(timePassed >= timeNeeded):
		fadeTimer.stop()
		if($Fader.modulate.a > 0.5):
			get_tree().change_scene(fadeTo)
	else:
		fadeTimer.start(CHECK_LENGTH)
	pass