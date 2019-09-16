extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.



const CHANGE_TIME = 0.0125
const ACTION_TIME = 0.25
var actionTimer

var changeChar
var queuedAction
var charCount = 0
var visableChars = 0

var tempValue = ""

const MAIN_MENU = ['Next Level', 'Upgrades', 'Main Menu']


const ALL_EQUIPMENT = {
	#"pistol" : 4,
	#"smg" : 8
	}

const BASE_UNLOCK = {
	#"stealth" : 1000,
	"jump" : 1
	}

func _ready():
	actionTimer = Timer.new()
	actionTimer.connect("timeout", self, "RunQueuedAction")
	add_child(actionTimer)
	$Display.text = $Display.text + "\nGood job Unit " + String(SaveManager.get_run()) + "!"
	addLine("\nAwaiting input...")
	changeChar = CHANGE_TIME
	$Display.visible_characters = 18
	visableChars = 18
	updateCharCount()
	
	GenerateInputs(MAIN_MENU)
	
	pass # Replace with function body.


func GenerateInputs(options):
	for child in $Buttons.get_children():
		child.queue_free()
	for option in options:
		var button = Button.new()
		button.text = " [" + option + "] "
		button.connect("button_down", self, "ButtonInput", [option])
		$Buttons.add_child(button)
	
func ButtonInput(input):
	if input == "Main Menu":
		addLine("gis exit\nExiting environment...")
		if !queuedAction:
			queuedAction = input
	elif input == "Next Level":
		addLine("gis run unit " + String(SaveManager.get_run()))
		if !queuedAction:
			queuedAction = input
	elif input == "Upgrades":
		addLine("gis config unit " + String(SaveManager.get_run()))
		if !queuedAction:
			queuedAction = input
	elif input == "Back":
		addLine("X")
		if !queuedAction:
			queuedAction = input
	elif input == "Equipment":
		addLine("2")
		if !queuedAction:
			queuedAction = input
	elif input == "Abilities":
		addLine("1")
		if !queuedAction:
			queuedAction = input
	elif input.to_lower() in SaveManager.get_equipment():
		addLine("gis access equipment " + input.to_lower())
		if !queuedAction:
			queuedAction = input
	elif input.to_lower() in SaveManager.get_actions():
		addLine("gis access upgrade " + input.to_lower())
		if !queuedAction:
			queuedAction = input
	elif input == "Equip":
		addLine("1")
		if !queuedAction:
			queuedAction = input
	elif input == "Upgrade":
		addLine("1")
		if !queuedAction:
			queuedAction = input
	elif input == "Unequip":
		addLine("1")
		if !queuedAction:
			queuedAction = input
	elif input == "Buy Equipment":
		addLine("3")
		if !queuedAction:
			queuedAction = input
	elif input.to_lower() in ALL_EQUIPMENT:
		addLine("gis equipment purchase " + input.to_lower())
		if !queuedAction:
			queuedAction = input
	else:
		addLine("Error 404! Command `button:" + input + "` not found!") 

func capFirst(inputVal):
	return inputVal.capitalize()[0] + inputVal.substr(1, len(inputVal))

func RunQueuedAction():
	if queuedAction == "Main Menu":
		get_tree().change_scene("res://Nodes/Title.tscn")
	elif queuedAction == "Next Level":
		get_tree().change_scene("res://Nodes/Game.tscn")
	elif queuedAction == "Upgrades":
		clearConsole()
		addLine("Upgrade Chips: " + String(SaveManager.get_upgrade_points()) + "\n\n")
		addLine("Select upgrade category:")
		addLine("1. Abilities")
		addLine("2. Equipment")
		addLine("3. Buy Equipment")
		addLine("\nX. Back")
		GenerateInputs(['Abilities', 'Equipment', 'Buy Equipment', 'Back'])
	elif queuedAction == "Buy Equipment":
		clearConsole()
		addLine("Upgrade Chips: " + String(SaveManager.get_upgrade_points()) + "\n\n")
		addLine("Equipment:")
		var i = 1
		var tempInputs = []
		for equipment in ALL_EQUIPMENT:
			if !(equipment in SaveManager.get_equipment()):
				tempInputs.append(capFirst(equipment))
				addLine(String(i) + ". " + capFirst(equipment) + " (COST " + String(ALL_EQUIPMENT[equipment]) + ")")
				i += 1
		GenerateInputs(tempInputs + ['Upgrades'])
	elif queuedAction == "Back":
		GenerateInputs(MAIN_MENU)
		clearConsole()
	elif queuedAction == "Equipment":
		clearConsole()
		addLine("Upgrade Chips: " + String(SaveManager.get_upgrade_points()) + "\n\n")
		addLine("Equipment:")
		var i = 1
		var tempInputs = []
		for equip in SaveManager.get_equipment():	
			var suffix = ""
			if equip == SaveManager.get_equiped():
				suffix = " (EQUIPED)"
			addLine(String(i) + ". " + equip.capitalize()[0] + equip.substr(1, len(equip)) + suffix)
			tempInputs.append(equip.capitalize()[0] + equip.substr(1, len(equip)))
			i += 1
		addLine('\nX. Back')
		
		GenerateInputs(tempInputs + ["Upgrades"])
	elif queuedAction == "Abilities":
		clearConsole()
		addLine("Upgrade Chips: " + String(SaveManager.get_upgrade_points()) + "\n\n")
		addLine("Abilities:")
		var i = 1
		var tempInputs = []
		for action in SaveManager.get_actions():	
			addLine(String(i) + ". " + action.capitalize()[0] + action.substr(1, len(action)))
			tempInputs.append(action.capitalize()[0] + action.substr(1, len(action)))
			i += 1
		addLine('\nX. Back')
		
		GenerateInputs(tempInputs + ["Upgrades"])
	elif queuedAction.to_lower() in SaveManager.get_equipment():
		clearConsole()
		addLine("Equipment: " + queuedAction)
		addLine("")
		var tempInputs = []
		if(queuedAction.to_lower() == SaveManager.get_equiped()):
			tempInputs.append("Unequip")
			addLine("1. Unequip")
		else:
			tempInputs.append("Equip")
			addLine("1. Equip")
		addLine("\nX. Back")
		tempValue = queuedAction.to_lower()
		GenerateInputs(tempInputs + ["Equipment"])
	elif queuedAction.to_lower() in SaveManager.get_actions():
		clearConsole()
		addLine("Upgrade Chips: " + String(SaveManager.get_upgrade_points()) + "\n\n")
		addLine("Ability: " + queuedAction)
		addLine("Level: " + String(SaveManager.get_action_value(queuedAction.to_lower())))
		addLine("")
		var pointsToUpgrade = 1 * int(SaveManager.get_action_value(queuedAction.to_lower()))
		if queuedAction.to_lower() in BASE_UNLOCK:
			pointsToUpgrade += BASE_UNLOCK[queuedAction.to_lower()]
		var tempInputs = []
		tempInputs.append("Upgrade")
		addLine("1. Upgrade (" + String(pointsToUpgrade) + " Points)")
		addLine("\nX. Back")
		tempValue = queuedAction.to_lower()
		GenerateInputs(tempInputs + ["Abilities"])
	elif queuedAction == "Equip":
		SaveManager.set_equiped(tempValue)
		addLine("\nEquiped: " + tempValue.capitalize()[0] + tempValue.substr(1, len(tempValue)))
		queuedAction = "Equipment"
		actionTimer.stop()
		return
	elif queuedAction == "Upgrade":
		var UPGRADE_COST = 1 * int(SaveManager.get_action_value(tempValue.to_lower()))
		if tempValue.to_lower() in BASE_UNLOCK:
			UPGRADE_COST += BASE_UNLOCK[tempValue.to_lower()]
		if (SaveManager.get_upgrade_points() >= UPGRADE_COST):
			SaveManager.change_upgrade_points(-1 * UPGRADE_COST)
			SaveManager.set_action_value(tempValue, SaveManager.get_action_value(tempValue) + 1)
			addLine("\nUpgraded: " + tempValue.capitalize()[0] + tempValue.substr(1, len(tempValue)))
		else:
			addLine("\nNot enough upgrade chips!")
		queuedAction = tempValue
		actionTimer.stop()
		return
	elif queuedAction == "Unequip":
		SaveManager.set_equiped("none")
		addLine("\nUnequiped: " + tempValue.capitalize()[0] + tempValue.substr(1, len(tempValue)))
		queuedAction = "Equipment"
		actionTimer.stop()
		return
	elif queuedAction.to_lower() in ALL_EQUIPMENT:
		var cost = ALL_EQUIPMENT[queuedAction.to_lower()]
		if (SaveManager.get_upgrade_points() >= cost):
			SaveManager.change_upgrade_points(-1 * cost)
			addLine("Purchased: " + queuedAction)
			SaveManager.unlock_equipment(queuedAction.to_lower())
		else:
			addLine("\nNot enough upgrade chips!")
		queuedAction = "Buy Equipment"
		return
	else:
		addLine("Error 404! Command `action:" + queuedAction + "` not found!")
	queuedAction = null
	addLine("\nAwaiting input...")
	actionTimer.stop()

func _process(delta):
	if(visableChars < charCount):
		if(changeChar <= 0):
			visableChars += 4
			$Display.visible_characters = visableChars
			changeChar = CHANGE_TIME
		else:
			changeChar -= delta
	else:
		changeChar = CHANGE_TIME
		if queuedAction && actionTimer.is_stopped():
			actionTimer.start(ACTION_TIME)

func addLine(line):
	$Display.text = $Display.text + "\n" + line
	updateCharCount()
	
func clearConsole():
	$Display.visible_characters = 0
	$Display.text = ""
	visableChars = 0
	updateCharCount()
	
func updateCharCount():
	charCount = $Display.get_total_character_count()
