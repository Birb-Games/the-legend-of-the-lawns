class_name Settings

const SETTINGS_PATH: String = "user://settings.json"

# Volume
static var master_volume: float = 1.0
static var lawn_mower_volume: float = 1.0
static var ui_volume: float = 1.0

# Reset settings values to their default
static func reset() -> void:
	master_volume = 1.0
	lawn_mower_volume = 1.0
	ui_volume = 1.0

static func save() -> void:
	var data = {
		"master_volume" : master_volume,
		"lawn_mower_volume" : lawn_mower_volume,
		"ui_volume" : ui_volume,
	}
	var json_str = JSON.stringify(data)
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	file.store_line(json_str)

static func load() -> void:
	# Check if the file exists, if it doesn't then create it
	if !FileAccess.file_exists(SETTINGS_PATH):
		print("%s does not exist, creating..." % SETTINGS_PATH)
		save()
		return

	var file = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	var line = file.get_line()
	var json = JSON.new()
	if json.parse(line) != OK:
		printerr("Error when parsing %s" % SETTINGS_PATH)
		return

	master_volume = clamp(Save.get_val(json.data, "master_volume", 1.0), 0.0, 1.0)
	lawn_mower_volume = clamp(Save.get_val(json.data, "lawn_mower_volume", 1.0), 0.0, 1.0)
	ui_volume = clamp(Save.get_val(json.data, "ui_volume", 1.0), 0.0, 1.0)

static func apply_settings() -> void:
	# Apply master volume
	var master = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master, linear_to_db(master_volume))
	# Apply lawn mower volume
	var lawn_mower = AudioServer.get_bus_index("LawnMower")
	AudioServer.set_bus_volume_db(lawn_mower, linear_to_db(lawn_mower_volume))
	# Apply UI volume
	var ui = AudioServer.get_bus_index("UI")
	AudioServer.set_bus_volume_db(ui, linear_to_db(ui_volume))
