class_name Inventory

var slots: Array[InventoryItem] = []
var inventory_level: int = 0

func get_slot_count() -> int:
	match inventory_level:
		0:
			return 2
		1:
			return 3
		_:
			return 4

# Returns true if an item was successfully added, false otherwise
func add_item(id: String) -> bool:
	if full():
		return false
	slots.append(InventoryItem.new(id))
	return true

func get_item(slot_index: int) -> InventoryItem:
	if slot_index < 0 or slot_index >= slots.size():
		return null
	return slots[slot_index]

func remove_item(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= slots.size():
		return
	slots.remove_at(slot_index)

func full() -> bool:
	return slots.size() >= get_slot_count()

func update(delta: float, reset_cooldown: bool) -> void:
	# Update item cooldown
	for item: InventoryItem in slots:
		if reset_cooldown:
			item.cooldown = 0.0
		else:
			item.cooldown = max(item.cooldown - delta, 0.0)

func _to_string() -> String:
	var str: String = ""
	for item: InventoryItem in slots:
		str += str(item) + ","
	return str

static func parse(str: String) -> Inventory:
	var inventory: Inventory = Inventory.new()
	var split = str.split(",")
	for substr in split:
		if substr.is_empty():
			continue
		var item: InventoryItem = InventoryItem.parse(substr)
		if item:
			inventory.slots.append(item)
	return inventory
