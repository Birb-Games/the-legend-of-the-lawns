extends Node2D

var lawns: Array[Node2D] = []
var lawnmower: RigidBody2D = preload("res://scenes/lawnmower.tscn").instantiate()

func _ready() -> void:
	lawns.append(preload("res://scenes/lawn.tscn").instantiate())

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("shoot"):
		add_child(lawnmower)
		add_child(lawns[0])
