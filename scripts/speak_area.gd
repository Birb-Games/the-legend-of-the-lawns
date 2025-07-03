class_name NeighborNPC

extends AnimatedSprite2D

var player_in_area: bool = false

@export var display_name: String = "Neighbor"
@export var lawn_template: PackedScene
@export_multiline var possible_dialog: PackedStringArray = [
	"Oh, you want to mow my lawn? I suppose it is a bit overgrown...",
	"My lawn needs to be mowed today but I'm too lazy.",
]
@export_multiline var reject_dialog: PackedStringArray = [
	"Sorry, my lawn doesn't need to be mowed today.",
]
# the range in which the wage for the player is generated
# as the game progresses, these likely should increase but that can be dealt
# with later
@export var wage: int = 10
# When the neighbor will be first available
@export var start_day: int = 0
@export_multiline var unavailable_msg: String = "The door is locked..."
# How frequently they need their lawn mowed
@export var mowing_frequency: int = 1
var mow_cooldown: int = 0

var current_dialog: String = ""

func _ready() -> void:
	hide()
	play(animation)

func unavailable() -> bool:
	return $/root/Main.current_day < start_day

# Returns true if the mow cool down is above 0
func reject() -> bool:
	return mow_cooldown > 0

func set_cooldown() -> void:
	mow_cooldown = mowing_frequency

func update_cooldown() -> void:
	mow_cooldown -= 1
	mow_cooldown = max(mow_cooldown, 0)

func generate_dialog():
	if unavailable():
		current_dialog = unavailable_msg
		return
	if reject():
		if len(reject_dialog) == 0:
			return
		current_dialog = reject_dialog[randi() % len(reject_dialog)]
		return
	if len(possible_dialog) == 0:
		return
	current_dialog = possible_dialog[randi() % len(possible_dialog)]

func _process(_delta: float) -> void:
	# Have the player interact with the neighbor
	if Input.is_action_just_pressed("interact") and player_in_area and !visible:
		generate_dialog()
		if !unavailable():
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
