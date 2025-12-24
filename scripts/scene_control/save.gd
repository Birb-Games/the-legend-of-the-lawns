class_name Save

class SaveEntry:
	var player_name: String = "Billy"
	var current_day: int = 1
	var money: int = 0
	var file_name: String
	
	func _init(save_file_name: String) -> void:
		self.file_name = save_file_name
	
	func get_path() -> String:
		return "user://saves/%s" % self.file_name

	func get_display() -> String:
		var display: String = ""
		display += " > %s - Day %d ($%d)\n" % [ self.player_name, self.current_day, self.money ]
		display += "\n '%s'" % self.file_name
		return display

static func get_save_path(player_name: String, id: int = 0) -> String:
	if id == 0:
		return "user://saves/" + player_name.to_lower() + ".save"
	else:
		return "user://saves/" + player_name.to_lower() + "_" + str(id + 1) + ".save"

# Returns an array of the save files the user currently has
static func get_save_entries() -> Array:
	var saves: Array = []
	var dir = DirAccess.open("user://saves/")
	if !dir:
		printerr("Error: could not open saves directory!")
		return saves
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while !file_name.is_empty():
		if !dir.current_is_dir():
			var entry: SaveEntry = SaveEntry.new(file_name)
			
			var save_file = FileAccess.open(entry.get_path(), FileAccess.READ)
			if !save_file:
				printerr("Error: could not read ", file_name)
				continue
			var line = save_file.get_line()
			var json = JSON.new()
			var parse_result = json.parse(line)
			if parse_result != OK:
				printerr("JSON parse error: ", json.get_error_message(), " in ", file_name)
				saves.push_back(entry)
				file_name = dir.get_next()
				continue
			var display_data = json.data

			entry.player_name = display_data["player_name"]
			if entry.player_name.is_empty():
				entry.player_name = "Billy"
			entry.money = max(display_data["money"], 0)
			entry.current_day = max(display_data["current_day"], 1)
			
			saves.push_back(entry)
		file_name = dir.get_next()
	return saves
