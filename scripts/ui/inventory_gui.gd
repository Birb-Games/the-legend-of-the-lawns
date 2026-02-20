extends Control

class_name InventoryGUI

@onready var player: Player = $/root/Main/Player
@onready var hud = $/root/Main/HUD
@onready var main: Main = $/root/Main
var slots: Array[InventorySlot] = []
var selected: int = 0
@onready var default_inventory_x: float = $InventoryContainer.position.x
const SLIDE_SPEED: float = 480.0

const SCROLL_DELAY = 0.1
var scroll_timer: float = 0.0
const KEYS: Array = [
	KEY_1,
	KEY_2,
	KEY_3,
	KEY_4,
	KEY_5,
	KEY_6,
	KEY_7,
	KEY_8,
]

func _ready() -> void:
	# Get the list of slots
	var rows = $InventoryContainer.get_children()
	rows.reverse()
	for row in rows:
		for slot: InventorySlot in row.get_children():
			slots.append(slot)

func can_use_inventory() -> bool:
	return visible and !player.water_gun.visible and !player.lawn_mower_active() and !get_tree().paused

func update_selected_slot_with_keys() -> void:
	if !can_use_inventory():
		return

	# Use keys to select the slot
	var prev_selected: int = selected
	for i in range(KEYS.size()):
		if Input.is_key_pressed(KEYS[i]) and i < player.inventory.get_slot_count():
			selected = i
	if prev_selected != selected:
		main.play_sfx("Click", true)
	selected = clamp(selected, 0, player.inventory.get_slot_count() - 1)

func _input(event: InputEvent) -> void:
	# Do not process input if hidden
	if !can_use_inventory():
		return

	if event is InputEventMouseButton:
		if !event.is_pressed():
			return
		if scroll_timer > 0.0:
			return
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			selected += 1
			scroll_timer = SCROLL_DELAY
			main.play_sfx("Click", true)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			selected -= 1
			scroll_timer = SCROLL_DELAY
			main.play_sfx("Click", true)
		while selected < 0:
			selected += player.inventory.get_slot_count()
		selected %= player.inventory.get_slot_count()

func update_position(delta: float) -> void:
	var disabled_x: float = -$InventoryContainer.size.x - 16.0
	# Do not show the inventory if the water gun is being held or if the
	# player is holding the lawn mower
	if player.water_gun.visible or player.lawn_mower_active():
		# Do not display the inventory, slide to the left
		if $InventoryContainer.position.x > disabled_x:
			$InventoryContainer.position.x -= delta * SLIDE_SPEED
	else:
		# Display inventory, slide to the right
		if $InventoryContainer.position.x < default_inventory_x:
			$InventoryContainer.position.x += delta * SLIDE_SPEED
	$InventoryContainer.position.x = clamp(
		$InventoryContainer.position.x, 
		disabled_x, 
		default_inventory_x
	)

func use_item() -> void:
	if !can_use_inventory():
		return
	if !Input.is_action_just_pressed("shoot_primary"):
		return
	if !main.lawn_loaded:
		return
	
	var item: InventoryItem = player.inventory.get_item(selected)
	if item:
		if item.cooldown > 0.0:
			return
		item.use(main)
		# Remove item if the player used it too many times
		if item.uses_left <= 0:
			player.inventory.remove_item(selected)

func _process(delta: float) -> void:
	update_position(delta)

	# Hide the whole display
	visible = !(hud.npc_menu_open() or hud.quest_screen_open() or player.health <= 0)
	if $/root/Main/HUD/MainMenu.visible:
		hide()
	if !visible:
		return

	# Update display of the inventory slots 
	for i in range(slots.size()):
		var slot = slots[i]
		if i >= player.inventory.get_slot_count():
			slot.hide()
		else:
			var item: InventoryItem = player.inventory.get_item(i)
			slot.show()
			slot.set_item_icon(item)
			if i == selected:
				slot.show_selection_arrow()
				slot.set_icon_scale(1.2)
			else:
				slot.hide_selection_arrow()
				slot.set_icon_scale(1.0)

	# Hide/show rows based on whether all of their children are hidden
	for row in $InventoryContainer.get_children():
		var all_hidden: bool = true
		for slot: InventorySlot in row.get_children():
			all_hidden = all_hidden and !slot.visible
		if all_hidden:
			row.hide()
		else:
			row.show()
	
	scroll_timer = max(scroll_timer - delta, 0.0)
	update_selected_slot_with_keys()
	use_item()

	# Update selected slot
	var selected_slot: InventorySlot = get_node_or_null("Selected")
	if selected_slot:
		if main.lawn_loaded:
			var selected_item: InventoryItem = player.inventory.get_item(selected)
			if selected_item:
				if can_use_inventory():
					selected_slot.modulate = Color8(255, 255, 255)
				else:
					selected_slot.modulate = Color8(255, 255, 255, 64)
				selected_slot.show()
				selected_slot.set_item_icon(selected_item)
				selected_slot.hide_selection_arrow()
			else:
				selected_slot.hide()
		else:
			selected_slot.hide()

func reset() -> void:
	selected = 0
