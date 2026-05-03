extends Area2D

class_name Buy

var player_in_area: bool = false

static var buy_item_list: Array = []
@onready var player: Player = $/root/Main/Player
@export var display_name: String
@export var id: String
@export_multiline var description: String
@export_multiline var buy_text: String
@export var price: int = 1
var bought: bool = false

const ITEM_LIST: Array = [
	"chocolate", 
	"soda", 
	"ice_cream", 
	"tomato_seeds", 
	"boom_shroom_spores", 
	"gasoline",
	"shield_generator", 
	"electric_doodad", 
	"insecticide", 
	"drone_controller", 
	"fireworks",
	"weedkiller", 
	"acidic_weedkiller", 
	"super_weedkiller", 
	"ultra_weedkiller",
	"water_bottle_pack",
	"water_jug",
	"ice",
]

const ID_TO_LEVEL: Dictionary = {
	# Juices
	"apple_juice" : 0,
	"orange_juice" : 1,
	"grape_juice" : 2,
	"carrot_juice" : 3,
	"milk" : 4,
	"golden_apple_juice" : 5,
	# Shoes
	"red_shoes" : 0,
	"blue_shoes" : 1,
	"gray_shoes" : 2,
	"athlete_shoes" : 3,
	# Backpacks
	"backpack0" : 0,
	"backpack1" : 1,
	"backpack2" : 2,
	"backpack3" : 3,
	# Watches
	"watch" : 0,
	"digital_watch" : 1,
	"pocket_watch" : 2,
	"rollx_watch" : 3,
	# Helmets
	"hat" : 0,
	"bike_helmet" : 1,
	"football_helmet" : 2,
	"combat_helmet" : 3,
	"astronaut_helmet" : 4,
}

func _ready() -> void:
	$AnimatedSprite2D.animation = id
	$AnimatedSprite2D.play($AnimatedSprite2D.animation)

static func update_buy_list() -> void:
	for item: Buy in buy_item_list:
		item.bought = false
		item.player_in_area = false
		if item.available():
			item.show()
		else:
			item.hide()

func available() -> bool:
	match id:
		"apple_juice", "orange_juice", "grape_juice", "milk", "carrot_juice", "golden_apple_juice":
			return player.max_health_level == ID_TO_LEVEL[id]
		"red_shoes", "blue_shoes", "gray_shoes", "athlete_shoes":
			return player.speed_level == ID_TO_LEVEL[id]
		"backpack0", "backpack1", "backpack2", "backpack3":
			return player.inventory.inventory_level == ID_TO_LEVEL[id]
		"watch", "digital_watch", "pocket_watch", "rollx_watch":
			return player.time_bonus_level == ID_TO_LEVEL[id]
		"hat", "bike_helmet", "football_helmet", "combat_helmet", "astronaut_helmet":
			return player.armor_level == ID_TO_LEVEL[id]
		_:
			return !bought

func buy() -> void: 
	match id:
		"apple_juice", "orange_juice", "grape_juice", "milk", "carrot_juice", "golden_apple_juice":
			player.max_health_level = ID_TO_LEVEL[id] + 1
		"red_shoes", "blue_shoes", "gray_shoes", "athlete_shoes":
			player.speed_level = ID_TO_LEVEL[id] + 1
		"backpack0", "backpack1", "backpack2", "backpack3":
			player.inventory.inventory_level = ID_TO_LEVEL[id] + 1
		"watch", "digital_watch", "pocket_watch", "rollx_watch":
			player.time_bonus_level = ID_TO_LEVEL[id] + 1
		"hat", "bike_helmet", "football_helmet", "combat_helmet", "astronaut_helmet":
			player.armor_level = ID_TO_LEVEL[id] + 1
		_:
			if id in ITEM_LIST:
				if !player.inventory.add_item(id):
					return
	bought = true
	var main: Main = $/root/Main
	main.money = max(0, main.money - price)
	player.interact_text = ""

func is_item() -> bool:
	return id in ITEM_LIST

func _process(_delta: float) -> void:
	if !available():
		hide()
		return

	if !visible:
		return
	
	if player_in_area:
		player.interact_text = get_interact_text()

func get_interact_text() -> String:
	if price == 0:
		return "Pick up %s - [SPACE]" % display_name
	return "Buy %s - [SPACE]" % display_name

func _on_body_entered(body: Node2D) -> void:
	if !available():
		return
	if !is_inside_tree():
		return
	if body is Player:
		player_in_area = true

func _on_body_exited(body: Node2D) -> void:
	if !available():
		return
	if body is Player:
		if body.interact_text == get_interact_text():
			body.interact_text = ""
		player_in_area = false

func _on_tree_exited() -> void:
	var index: int = 0
	for item: Buy in buy_item_list:
		if item == self:
			break
		index += 1
	buy_item_list.remove_at(index)

func _on_tree_entered() -> void:	
	buy_item_list.append(self)
