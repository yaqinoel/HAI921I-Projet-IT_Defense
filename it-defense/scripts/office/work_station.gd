class_name WorkStation
extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $employee
@onready var intrusion_area: Area2D = $IntrusionArea
@onready var computer_on: Sprite2D = $Computer/pc_on
@onready var computer_off: Sprite2D = $Computer/pc_off

var is_working: bool = true

func _ready() -> void:
	animated_sprite.play("work")
	
	intrusion_area.area_entered.connect(_on_intrusion_area_entered)
	
	
func _on_intrusion_area_entered(area: Area2D) -> void:
	var danger := area.get_parent() as Danger
	
	if danger == null:
		return

	if danger.is_dying or danger.is_invading:
		return

	danger.invade()
	
	set_work_status(false)


func set_work_status(value: bool) -> void:
	is_working = value
	computer_on.visible = value
	computer_off.visible = not value
