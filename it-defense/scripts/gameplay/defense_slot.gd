class_name DefenseSlot extends Node2D

var placed_defense: Node2D

func is_available() -> bool:
	return not is_instance_valid(placed_defense)
