extends Panel

@onready var player: Player = $/root/Main/Player
const MARGIN_X: float = 30.0
const MARGIN_Y: float = 48.0
var top_left: Vector2 = Vector2.ZERO
var bottom_right: Vector2 = Vector2.ZERO
const OFFSET: Vector2 = Vector2(0.0, -10.0)
@onready var quest_screen: QuestScreen = get_parent().get_parent()
var house_positions: Array = []

func get_map_pos(pos: Vector2) -> Vector2:
	var norm_x: float = (pos.x - top_left.x) / (bottom_right.x - top_left.x)
	var norm_y: float = (pos.y - top_left.y) / (bottom_right.y - top_left.y)
	var map_x = MARGIN_X + norm_x * (size.x - 2.0 * MARGIN_X)
	var map_y = MARGIN_Y + norm_y * (size.y - 2.0 * MARGIN_Y)
	return Vector2(map_x, map_y) + OFFSET

func out_of_map_bounds(pos: Vector2) -> bool:
	return pos.x < MARGIN_X / 4.0 or pos.x > size.x - MARGIN_X / 4.0 or pos.y < MARGIN_Y / 4.0 or pos.y > size.y - MARGIN_Y / 4.0

func load_map() -> void:
	$HouseIcon.show()

	var first: bool = true
	var store_pos: Vector2 = Vector2.ZERO
	for child: Node2D in $/root/Main/Neighborhood/Houses.get_children():
		if child.name == "Store":
			store_pos = child.global_position
			continue
		if first:
			top_left = child.global_position
			bottom_right = child.global_position
			first = false
		house_positions.push_back(child.global_position)	
		top_left.x = min(top_left.x, child.global_position.x)
		top_left.y = min(top_left.y, child.global_position.y)
		bottom_right.x = max(bottom_right.x, child.global_position.x)
		bottom_right.y = max(bottom_right.y, child.global_position.y)
	bottom_right.y += 48.0
	
	# Place the icons
	for pos: Vector2 in house_positions:
		var map_pos: Vector2 = get_map_pos(pos)
		var icon: Sprite2D = $HouseIcon.duplicate()
		icon.position = map_pos
		add_child(icon)
	
	$StoreIcon.position = get_map_pos(store_pos)
	
	$HouseIcon.hide()

func _ready() -> void:
	load_map()

func _process(_delta: float) -> void:
	$PlayerIcon.position = get_map_pos(player.global_position)
	$PlayerIcon.visible = !out_of_map_bounds($PlayerIcon.position)

	if quest_screen.selected >= 0 and quest_screen.selected < quest_screen.neighbor_paths.size():
		$Circle.show()

		# Find the closest house
		var neighbor: NeighborNPC = get_node_or_null(quest_screen.neighbor_paths[quest_screen.selected])
		if neighbor:
			var closest_dist: float = -1.0
			var closest_pos: Vector2 = Vector2.ZERO
			for pos: Vector2 in house_positions:
				var dist: float = (pos - neighbor.global_position).length()
				if closest_dist < 0.0 or dist < closest_dist:
					closest_dist = dist
					closest_pos = pos
			$Circle.position = get_map_pos(closest_pos)
	else:
		$Circle.hide()
