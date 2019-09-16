extends Label

export var time_to_show = 4.0
export var fade_after_show = true
#Hide all charafcters on start
func _ready():
	show_text(time_to_show)
	visible_characters = 0


var timePassed = 0 #Current amount of time spend displaying te
const CHECK_LENGTH = 0.05 #Interval to check for updates
var timeNeeded = 0 #Time that it takes to display the text
var timer #Timer object
var fadeTimer #Timer object

func show_text(seconds):
	timeNeeded = seconds
	timePassed = 0
	if(!timer):
		timer = Timer.new()
		add_child(timer)
		timer.connect("timeout", self, "on_timeout")
	timer.start(CHECK_LENGTH)
	
func fade_text(seconds):
	timeNeeded = seconds
	timePassed = 0
	if(!fadeTimer):
		fadeTimer = Timer.new()
		add_child(fadeTimer)
		fadeTimer.connect("timeout", self, "on_fade_timeout")
	fadeTimer.start(CHECK_LENGTH)

func on_fade_timeout():
	timePassed += CHECK_LENGTH
	modulate.a = 1 - (timePassed/timeNeeded)
	if(timePassed >= timeNeeded):
		fadeTimer.queue_free()
	else:
		fadeTimer.start(CHECK_LENGTH)
	pass

func on_timeout():
	timePassed += CHECK_LENGTH
	visible_characters = (timePassed/timeNeeded) * get_total_character_count()
	if(timePassed >= timeNeeded):
		timer.queue_free()
		if(fade_after_show):
			fade_text(2)
	else:
		timer.start(CHECK_LENGTH)
	pass