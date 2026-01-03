extends Sprite2D

@export var point_to: NodePath
@export var min_dist: float = 0.0
@export var max_dist: float = 640.0
@onready var y_offset: float = position.y
@onready var dist: float = position.x
@onready var default_scale: Vector2 = scale
const MIN_MULTIPLIER = 0.5
const MAX_MULTIPLIER = 1.25

func _process(_delta: float) -> void:
	var target_node: Node = get_node_or_null(point_to)
	# If the target node doesn't exist, hide the arrow
	if target_node == null:
		hide()
		return

	var parent_pos: Vector2 = global_position - position + Vector2(0.0, y_offset)
	var diff: Vector2 = target_node.global_position - parent_pos
	if diff.length() <= max(min_dist, 0.0):
		hide()
		return

	show()

	# Have the arrow point to the target node
	position = diff.normalized() * dist + Vector2(0.0, y_offset)
	rotation = diff.normalized().angle()
	var sample: float = 1.0 - (diff.length() - min_dist) / (max_dist - min_dist)
	var multiplier: float = clamp(MIN_MULTIPLIER + (MAX_MULTIPLIER - MIN_MULTIPLIER) * sample, MIN_MULTIPLIER, MAX_MULTIPLIER)
	scale = default_scale * multiplier
