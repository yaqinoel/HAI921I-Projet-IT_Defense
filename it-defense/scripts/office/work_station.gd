class_name WorkStation
extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $employee
@onready var intrusion_area: Area2D = $IntrusionArea


func _ready() -> void:
	animated_sprite.play("work")
	
	intrusion_area.area_entered.connect(_on_intrusion_area_entered)
	
	
func _on_intrusion_area_entered(area: Area2D) -> void:
	var danger := area.get_parent() as Danger
	
	if danger == null:
		return

	if danger.is_dying or danger.is_invading:
		return

	danger.die()
