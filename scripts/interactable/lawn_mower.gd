class_name Lawnmower

extends StaticBody2D

var dir: String = "left"
@onready var player: Player = $/root/Main/Player

func _ready() -> void:
	$Shadows/ShadowLeft.show()

func get_dir_vec() -> Vector2:
	match dir:
		"left":
			return Vector2.LEFT
		"right":
			return Vector2.RIGHT
	return Vector2.ZERO

func set_animation() -> void:
	# Set shadows
	for shadow in $Shadows.get_children():
		shadow.hide()
	
	match dir:
		"left":
			$Shadows/ShadowLeft.show()
		"right":
			$Shadows/ShadowRight.show()
	
	$AnimatedSprite2D.animation = dir

func _process(_delta: float) -> void:
	set_animation()

func rect() -> Rect2:
	var r = $CollisionShape2D.shape.get_rect()
	r.position += get_sprite_pos()
	r.size *= 1.05
	return r

# Returns global position of the shadow
func get_sprite_pos() -> Vector2:
	return position + $AnimatedSprite2D.position
