class_name WorkStation
extends Node2D

@export var income_per_tick: int = 10
@export var income_interval: float = 2.0

@export var income_icon: Texture2D
@export var warning_icon: Texture2D
@export var recovery_icon: Texture2D

@onready var animated_sprite: AnimatedSprite2D = $employee
@onready var intrusion_area: Area2D = $IntrusionArea
@onready var computer_on: Sprite2D = $Computer/pc_on
@onready var computer_off: Sprite2D = $Computer/pc_off
@onready var income_timer: Timer = $IncomeTimer
@onready var recovery_timer: Timer = $RecoveryTimer
@onready var feedback: StatusFeedback = $StatusFeedback

signal income_generated(amount: int)
signal work_status_changed(working: bool)

var is_working: bool = true


func _ready() -> void:
	animated_sprite.play("work")
	
	income_timer.wait_time = income_interval
	income_timer.timeout.connect(_on_income_timer_timeout)
	income_timer.start()
	
	intrusion_area.area_entered.connect(_on_intrusion_area_entered)
	recovery_timer.timeout.connect(_on_recovery_timer_timeout)


# when danger enter collision area
func _on_intrusion_area_entered(area: Area2D) -> void:
	var danger := area.get_parent() as Danger
	
	if danger == null:
		return
		
	if danger.is_dying or danger.is_invading:
		return

	danger.invade()
	
	set_work_status(false, danger.data.attack_damage)


func _on_income_timer_timeout() -> void:
	if not is_working:
		return
	
	income_generated.emit(income_per_tick)
	
	play_income_effect()


func play_income_effect() -> void:
	feedback.show_feedback(
		income_icon,
		"+%d" % income_per_tick,
		0.7,
		Color("#ffd76a")
	)	


func set_work_status(work: bool, recovery_time: float = 0.0) -> void:
	var was_working := is_working
	
	is_working = work
	computer_on.visible = work
	computer_off.visible = not work

	if not work and recovery_time > 0.0:
		# accumulate recovery time affect by dangers
		var remaining_time := recovery_timer.time_left
		recovery_timer.start(remaining_time + recovery_time)
		
		# play stop work feedback animation
		feedback.show_feedback(
			warning_icon,
			"Hors service",
			0.0,
			Color("#ffb070")
		)
		
	elif work:
		recovery_timer.stop()
		
		# play recovery feedback animation only not was working
		if not was_working:
			feedback.show_feedback(
			recovery_icon,
			"Rétabli",
			0.7,
			Color("#9ce88d")
	)
	if was_working != is_working:
		work_status_changed.emit(is_working)


func _on_recovery_timer_timeout() -> void:
	set_work_status(true)
