class_name InventoryItem

const USE_COUNTS: Dictionary = {
	"chocolate" : 3,
	"soda" : 4,
	"ice_cream" : 4,
	"tomato_seeds" : 3,
	"boom_shroom_spores" : 5,
	"gasoline" : 3,
	"shield_generator" : 4,
}
const DEFAULT_USE_COUNT: int = 1

const COOLDOWNS: Dictionary = {
	"chocolate" : 25.0,
	"soda" : 30.0,
	"ice_cream" : 40.0,
	"tomato_seeds" : 80.0,
	"boom_shroom_spores" : 25.0,
	"gasoline" : 35.0,
	"shield_generator" : 90.0,
}
const DEFAULT_COOLDOWN: float = 1.0

const DISPLAY_NAMES: Dictionary = {
	"ice_cream" : "ice cream",
	"tomato_seeds" : "tomato seeds",
	"boom_shroom_spores" : "boom shroom spores",
	"shield_generator" : "shield generator",
}

var id: String = ""
var cooldown: float = 0.0
var uses_left: int = 1

static var tomato_boy_scene: PackedScene = preload("uid://crnj1ljbpuy2m")
static var boom_shroom_scene: PackedScene = preload("uid://cm4b5rcedfd1n")

static func get_use_count(item_id: String) -> int:
	if !(item_id in USE_COUNTS):
		return DEFAULT_USE_COUNT
	return USE_COUNTS[item_id]

static func get_cooldown(item_id: String) -> float:
	if !(item_id in COOLDOWNS):
		return DEFAULT_COOLDOWN 
	return COOLDOWNS[item_id]

func _init(item_id: String) -> void:
	id = item_id
	cooldown = 0.0
	uses_left = get_use_count(id)

func use(main: Main) -> void:
	# Only allow the item to be used on the lawn
	if !main.lawn_loaded:
		return
	if uses_left <= 0:
		return

	match id:
		"chocolate":
			# Do not heal the player if the player is at max health
			if main.player.health >= main.player.get_max_health():
				return
			main.player.heal(20)
			main.play_sfx("Eat")
		"soda":
			var prev_time = main.player.get_status_effect_time("speed")
			main.player.set_status_effect_time("speed", prev_time + 7.0)
			# Increase stamina
			main.player.stamina = min(main.player.stamina + 0.25, 1.0) 
			main.play_sfx("Drink")
		"ice_cream":
			# Do not heal the player if the player is at max health
			if main.player.health >= main.player.get_max_health():
				return
			var prev_time = main.player.get_status_effect_time("slowness")
			main.player.set_status_effect_time("slowness", prev_time + 17.0)
			main.player.heal(60)
			main.play_sfx("Eat")
		"tomato_seeds":
			var lawn: Lawn = main.get_node_or_null("Lawn")
			Spawning.spawn_at_point(
				lawn,
				lawn.get_node("MobileEnemies"),
				main.player.global_position,
				tomato_boy_scene,
			)
			main.play_sfx("Grass")
		"boom_shroom_spores":
			var lawn: Lawn = main.get_node_or_null("Lawn")
			var boom_shroom: Node2D = boom_shroom_scene.instantiate()
			boom_shroom.global_position = main.player.global_position
			if main.player.dir == "up":
				boom_shroom.global_position.y -= 2.0
			else:
				boom_shroom.global_position.y += 1.0
				var dir_vec: Vector2 = main.player.get_dir_vec()
				boom_shroom.global_position.x += dir_vec.x * 3.0
			lawn.add_child(boom_shroom)
			boom_shroom.scale = Vector2(0.0, 0.0)
			main.play_sfx("Grass")
		"gasoline":
			if main.player.lawn_mower_active():
				var prev_time = main.player.get_status_effect_time("gas")
				main.player.set_status_effect_time("gas", prev_time + 6.0)
				main.play_sfx("Gas")
			else:
				return
		"shield_generator":
			main.play_sfx("Zap")
			var prev_time = main.player.get_status_effect_time("shield")
			main.player.set_status_effect_time("shield", prev_time + 8.0)
		_:
			pass

	cooldown = get_cooldown(id)
	uses_left -= 1

func get_display_str() -> String:
	var display_name: String
	if id in DISPLAY_NAMES:
		display_name = DISPLAY_NAMES[id]
	else:
		display_name = id
	if uses_left == 1:
		return "[%s, 1 use left)]" % display_name
	else:
		return "[%s, %d uses left]" % [ display_name, uses_left ]

func _to_string() -> String:
	return "%s|%d" % [ id, uses_left ]

# Returns null if the parse failed
static func parse(s: String) -> InventoryItem:
	var split = s.split("|")
	if split.size() != 2:
		return null
	var item: InventoryItem = InventoryItem.new(split[0])
	var item_uses_left: int = int(split[1])
	if item_uses_left <= 0:
		return null
	item.uses_left = item_uses_left
	return item
