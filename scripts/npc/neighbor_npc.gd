# To avoid confusion,
# "NeighborNPC" refers to npcs that will give the player the opportunity to mow
# their yard while "NPC" refers to generic chracters that the player can talk
# to but can not take a job from.

class_name NeighborNPC

extends AnimatedSprite2D

var player_in_area: bool = false

@export var display_name: String = "Neighbor"
@export var always_visible: bool = false
@export var disabled: bool = false
@export var lawn_template: PackedScene
## How many lawns the player has to mow before unlocking this neighbor
@export var min_lawns_mowed: int = 0
## How frequently they need their lawn mowed
@export var mowing_frequency: int = 1
# The maximum number of times the player can mow the lawn and get paid
# (they can replay the lawn afterward but will not receive any money)
# Set this value to 0 if you want to allow the player to mow the lawn an
# unlimited number of times.
@export var mowing_limit: int = 0
var times_mowed: int = 0

@export_group("Wage Info")
@export var wage: int = 10
@export var wage_change: int = 0
@export var max_wage: int = 20
@export var bonus_base: int = 2
@export var max_bonus: int = 5
## How much they remove from the player's wage when they destroy each flower
@export var flower_penalty: int = 0
## How much they remove from the player's wage when they destroy each hedge
@export var hedge_penalty: int = 0

@export_group("Dialog")
@export_multiline var interact_text: String = "Press [SPACE] to knock on door."
@export_multiline var possible_dialog: PackedStringArray = [
	"Oh, you want to mow my lawn? I suppose it is a bit overgrown...",
	"My lawn needs to be mowed today but I'm too lazy.",
]
@export_multiline var reject_dialog: PackedStringArray = [
	"Sorry, my lawn doesn't need to be mowed today.",
]
@export_multiline var unavailable_msg: String = "The door is locked..."
@export_multiline var first_dialog: String = "Hello!"
@export_multiline var player_dialog: String = "I'm here to mow your lawn!"
@export_multiline var first_job_offer: String = "I suppose I could use some help with mowing my lawn today..."
var first_time: bool = true
var mow_cooldown: int = 0

var current_dialog: String = ""

func _ready() -> void:
	$Area2D/CollisionShape2D.disabled = disabled
	hide()
	play(animation)

func unavailable() -> bool:
	return $/root/Main.lawns_mowed < min_lawns_mowed

# Returns true if the mow cool down is above 0
func reject() -> bool:
	if mowing_limit_reached():
		return false
	return mow_cooldown > 0

func set_cooldown() -> void:
	mow_cooldown = mowing_frequency

func update_cooldown() -> void:
	mow_cooldown -= 1
	mow_cooldown = max(mow_cooldown, 0)

func generate_dialog() -> void:
	current_dialog = ""
	if unavailable():
		current_dialog = unavailable_msg
		return
	if reject():
		if len(reject_dialog) == 0:
			return
		current_dialog = reject_dialog[randi() % len(reject_dialog)]
		return	
	if first_time:
		current_dialog = first_dialog
		return
	
	if len(possible_dialog) == 0:
		return
	current_dialog = possible_dialog[randi() % len(possible_dialog)]

func _process(_delta: float) -> void:
	if disabled:
		return

	# Have the player interact with the neighbor
	if Input.is_action_just_pressed("interact") and player_in_area and (!visible or always_visible):
		generate_dialog()
		if !unavailable():
			show()
		$/root/Main/HUD.set_neighbor_menu(self)
	if always_visible:
		show()

func mowing_limit_reached() -> bool:
	return mowing_limit > 0 and times_mowed >= mowing_limit

func change_wage() -> void:
	if mowing_limit_reached():
		wage = 0
		bonus_base = 0
		max_bonus = 0
		return
	wage += wage_change
	wage = clamp(wage, 1, max_wage)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_area = true
		body.interact_text = interact_text

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_area = false	
		body.interact_text = ""

func save() -> Dictionary:
	return {
		"path" : get_path(),
		"times_mowed" : times_mowed,
		"wage" : wage,
		"first_time" : first_time,
		"mow_cooldown" : mow_cooldown,
	}

func load_from(data: Dictionary) -> void:
	times_mowed = data["times_mowed"]
	wage = data["wage"]
	first_time = data["first_time"]
	mow_cooldown = data["mow_cooldown"]

