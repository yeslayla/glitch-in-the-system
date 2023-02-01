extends Node

const SAVE_PATH = "res://save_raw.yaml"
const CONFIG_PATH = "res://config.cfg"

var _config_file = ConfigFile.new()

const RUN_PATH = "user://run.save"
const SAVE_PROGRESS = "user://progress.save"

var _settings = {
	"audio": {
		"mute": "false"
		}
	}

var _game_progress = {
		"upgrade_points" : "0",
		"equipment" : ["saber"],
		"equiped" : "saber",
		"actions" :
		{
			"jump" : 1
		}
	}

func _ready():
	if !FileAccess.file_exists(SAVE_PROGRESS):
		save_settings()
	else:
		load_settings()


func load_json(path):
	var file = FileAccess.open(path, FileAccess.READ)
	var tmp_text = file.get_as_text()
	var test_json_conv = JSON.new()
	test_json_conv.parse(tmp_text)
	var data = test_json_conv.get_data()
	return data

func write_json(path, data):
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))

func get_run():
	if(FileAccess.file_exists(RUN_PATH)):
		var _run_file = FileAccess.open(RUN_PATH, FileAccess.READ)
		var run_value = _run_file.get_64()
		return run_value
	else:
		return 0

func add_run():
	var currentRun = get_run()
	currentRun += 1
	var _run_file = FileAccess.open(RUN_PATH, FileAccess.WRITE)
	_run_file.store_64(currentRun)
	return currentRun


func save_progress():
	write_json(SAVE_PROGRESS, _game_progress)

func get_upgrade_points():
	if "upgrade_points" in _game_progress:
		return int(_game_progress["upgrade_points"])
	else:
		return 0

func change_upgrade_points(pts):
	_game_progress["upgrade_points"] = int(_game_progress["upgrade_points"]) + pts

func get_equipment():
	return _game_progress['equipment']

func get_equiped():
	return _game_progress['equiped']

func set_equiped(equip):
	_game_progress['equiped'] = equip
	save_progress()

func unlock_equipment(equip):
	_game_progress['equipment'].append(equip)
	save_progress()


func get_actions():
	var actions = []
	for action in _game_progress['actions']:
		actions.append(action)
	return actions

func get_action_value(action):
	return _game_progress['actions'][action]

func set_action_value(action, value):
	_game_progress['actions'][action] = value
	save_progress()


func save_settings():
	for section in _settings.keys():
		for key in _settings[section]:
			_config_file.set_value(section, key, _settings[section][key])
	_config_file.save(CONFIG_PATH)

func load_settings():
	var error = _config_file.load(CONFIG_PATH)
	if error != OK:
		print("Failed to load config file. Error: %s" % error)
		return -1

	for section in _settings.keys():
		for key in _settings[section]:
			var val = _config_file.get_value(section, key, null)
			_settings[section][key] = val

