extends Node

const SAVE_PATH = "res://save_raw.yaml"
const CONFIG_PATH = "res://config.cfg"

var _config_file = ConfigFile.new()

const RUN_PATH = "user://run.save"
var _run_file = File.new()

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
	var SaveFile = File.new()
	if !SaveFile.file_exists(SAVE_PROGRESS):
		save_settings()
	else:
		load_settings()
	
	
func load_json(path):
    var file = File.new()
    file.open(path, file.READ)
    var tmp_text = file.get_as_text()
    file.close()
    var data = parse_json(tmp_text)
    return data

func write_json(path, data):
	var file = File.new()
	file.open(path, file.WRITE)
	file.store_string(to_json(data))
	file.close()
	
func get_run():
	if(_run_file.file_exists(RUN_PATH)):
		_run_file.open(RUN_PATH, File.READ)
		var run_value = _run_file.get_64()
		_run_file.close()
		return run_value
	else:
		return 0
	
func add_run():
	var currentRun = get_run()
	currentRun += 1
	_run_file.open(RUN_PATH, File.WRITE)
	_run_file.store_64(currentRun)
	_run_file.close()
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
			
	pass