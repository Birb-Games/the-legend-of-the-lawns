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

func _ready() -> void:
	buy_item_list.append(self)
	$AnimatedSprite2D.animation = id

static func update_buy_list() -> void:
	for item: Buy in buy_item_list:
		if item.available():
			item.show()
		else:
			item.hide()

func available() -> bool:
	match id:
		"apple_juice":
			return player.max_health_level == 0
		"red_shoes":
			return player.speed_level == 0
		"backpack0":
			return player.inventory_level == 0
		"watch":
			return player.time_bonus_level == 0
		"bike_helmet":
			return player.armor_level == 0
		_:
			return true

func buy() -> void:
	var main: Main = $/root/Main
	main.money = max(0, main.money - price)
	player.interact_text = "" 
	match id:
		"apple_juice":
			player.max_health_level = max(player.max_health_level, 1)
		"red_shoes":
			player.speed_level = max(player.speed_level, 1)
		"backpack0":
			player.inventory_level = max(player.inventory_level, 1)
		"watch":
			player.time_bonus_level = max(player.time_bonus_level, 1)
		"bike_helmet":
			player.armor_level = max(player.armor_level, 1)
		_:
			pass

func _process(_delta: float) -> void:
	if !available():
		hide()
		return	
	
	if player_in_area:
		player.interact_text = get_interact_text()

func get_interact_text() -> String:
	return "Buy %s - [SPACE]" % display_name

func _on_body_entered(body: Node2D) -> void:
	if !available():
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
