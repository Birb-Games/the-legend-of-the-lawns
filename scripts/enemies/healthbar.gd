extends ColorRect

@export var health_gradient: Gradient

func update_bar(health: int, max_health: int) -> void:
	if health >= max_health:
		hide()
		return
	show()
	var perc = float(health) / float(max_health)
	var sz = size.x * perc
	$ColorRect.size.x = sz
	$ColorRect.color = health_gradient.sample(perc)
