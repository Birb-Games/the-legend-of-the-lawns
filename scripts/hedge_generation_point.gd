extends Node2D

## The minimum size of the hedge on the x and y axes
@export var min_size: Vector2i
## The maximum size of the hedge on the x and y axes
@export var max_size: Vector2i

## How likely this hedge is to be generated, between 0 and 1
@export var generation_chance: float = 1.0
