extends TextureRect

class_name InventorySlot

@onready var default_icon_scale: float = $Icon.scale.x
@export var gradient: Gradient

# Hides icon with empty id string
func set_item_icon(item: InventoryItem) -> void:
	if item == null:
		$Icon.hide()
		$DurabilityBackground.hide()
		$CooldownTimer.hide()
		return
	$Icon.show()
	$DurabilityBackground.show()
	$Icon.animation = item.id
	# Update durability bar
	if item.uses_left >= InventoryItem.get_use_count(item.id):
		$DurabilityBackground.hide()
	else:
		var perc: float = float(item.uses_left) / float(InventoryItem.get_use_count(item.id))
		$DurabilityBackground.show()
		$DurabilityBackground/DurabilityBar.size.x = $DurabilityBackground.size.x * perc
		$DurabilityBackground/DurabilityBar.color = gradient.sample(perc)

	# Update item cooldown timer
	if item.cooldown > 0.0:
		$Icon.modulate = Color8(255, 255, 255, 128)
		$CooldownTimer.show()
		$CooldownTimer.text = "%d" % int(ceil(item.cooldown))
	else:
		$Icon.modulate = Color8(255, 255, 255)
		$CooldownTimer.hide()

func hide_selection_arrow() -> void:
	$Selected.hide()

func show_selection_arrow() -> void:
	$Selected.show()

func set_icon_scale(scale_amt: float) -> void:
	$Icon.scale = Vector2(scale_amt, scale_amt) * default_icon_scale
