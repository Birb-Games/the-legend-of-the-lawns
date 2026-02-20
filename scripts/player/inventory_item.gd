class_name InventoryItem

const USE_COUNTS: Dictionary = {
	"chocolate" : 3,
}
const DEFAULT_USE_COUNT: int = 1

const COOLDOWNS: Dictionary = {
	"chocolate" : 25.0,
}
const DEFAULT_COOLDOWN: float = 1.0

var id: String = ""
var cooldown: float = 0.0
var uses_left: int = 1

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
		_:
			pass

	cooldown = get_cooldown(id)
	uses_left -= 1

func _to_string() -> String:
	return "%s|%d" % [ id, uses_left ]

# Returns null if the parse failed
static func parse(str: String) -> InventoryItem:
	var split = str.split("|")
	if split.size() != 2:
		return null
	var item: InventoryItem = InventoryItem.new(split[0])
	var uses_left: int = int(split[1])
	if uses_left <= 0:
		return null
	item.uses_left = uses_left
	return item
