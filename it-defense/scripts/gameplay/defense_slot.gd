class_name DefenseSlot extends Node2D

@export var detection_areas: Array[DangerDetectionArea] = []

var placed_defense: Node2D

func is_available() -> bool:
	return not is_instance_valid(placed_defense)
