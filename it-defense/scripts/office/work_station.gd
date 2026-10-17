class_name WorkStation
extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $employee

func _ready() -> void:
	animated_sprite.play("work")
