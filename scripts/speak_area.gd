class_name NeighborNPC

extends AnimatedSprite2D

var player_in_area: bool = false

@export var display_name: String
@export var lawn_template: PackedScene
@export_multiline var possible_dialog: PackedStringArray
@export_multiline var reject_dialog: PackedStringArray
# the range in which the wage for the player is generated
# as the game progresses, these likely should increase but that can be dealt
# with later
@export var wage: int
# When the neighbor will be first available
@export var start_day: int
@export_multiline var unavailable_msg: String
# How frequently they need their lawn mowed
@export var mowing_frequency: int = 1
var mow_cooldown: int = 0

var current_dialog: String = ""

func _ready() -> void:
	hide()
	play(animation)

func generate_dialog():
	if len(possible_dialog) == 0:
		return
	current_dialog = possible_dialog[randi() % len(possible_dialog)]

func _process(_delta: float) -> void:
	# Have the player interact with the neighbor
	if Input.is_action_just_pressed("interact") and player_in_area and !visible:
		generate_dialog()
		show()
		$/root/Main/HUD.set_neighbor_menu(self)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_area = true
		body.can_talk_to_neighbor = true

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_area = false
		body.can_talk_to_neighbor = false
