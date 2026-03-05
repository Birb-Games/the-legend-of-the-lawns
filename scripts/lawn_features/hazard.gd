class_name Hazard

# The amount of time between each hit of damage
var damage_delay: float = 1.0
# Damage timer, update this with _process
var damage_timer: float = 0.0
# Damage amount
var damage_amt: int = 0

static var presets: Dictionary = {
	"poison" : Hazard.new(0.6, 1),
}

func _init(dmg_delay: float, dmg_amt: int) -> void:
	damage_delay = dmg_delay
	damage_amt = dmg_amt

static func from_preset(preset_id: String) -> Hazard:
	if preset_id in presets:
		var preset: Hazard = presets[preset_id]
		return Hazard.new(preset.damage_delay, preset.damage_amt)
	return null


# Returns true if we should apply damage, false otherwise
func update(delta: float) -> bool:
	damage_timer += delta
	if damage_timer >= damage_delay:
		damage_timer = 0.0
		return true
	return false
