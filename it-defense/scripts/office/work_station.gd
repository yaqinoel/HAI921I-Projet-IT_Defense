class_name WorkStation
extends Node2D

@export var income_per_tick: int = 10
@export var income_interval: float = 2.0

@onready var animated_sprite: AnimatedSprite2D = $employee
@onready var intrusion_area: Area2D = $IntrusionArea
@onready var computer_on: Sprite2D = $Computer/pc_on
@onready var computer_off: Sprite2D = $Computer/pc_off
@onready var income_timer: Timer = $IncomeTimer

signal income_generated(amount: int)

var is_working: bool = true


func _ready() -> void:
	animated_sprite.play("work")
	
	income_timer.wait_time = income_interval
	income_timer.timeout.connect(_on_income_timer_timeout)
	income_timer.start()
	
	intrusion_area.area_entered.connect(_on_intrusion_area_entered)
	
	
func _on_intrusion_area_entered(area: Area2D) -> void:
	var danger := area.get_parent() as Danger
	
	if danger == null:
		return

	if danger.is_dying or danger.is_invading:
		return

	danger.invade()
	
	set_work_status(false)


func _on_income_timer_timeout() -> void:
	if not is_working:
		return
	
	income_generated.emit(income_per_tick)
	
	play_income_effect()


func play_income_effect() -> void:
	# TODO
	pass
	

func set_work_status(value: bool) -> void:
	is_working = value
	computer_on.visible = value
	computer_off.visible = not value
