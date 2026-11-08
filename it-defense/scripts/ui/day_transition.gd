class_name DayTransition
extends CanvasLayer

@export_range(0.05, 3.0) var fade_duration: float = 0.8
@export_range(0.05, 1.0) var text_fade_duration: float = 0.2
@export_range(0.05, 3.0) var text_hold_duration: float = 2.0

@onready var night_overlay: ColorRect = $Screen/NightOverlay
@onready var content: VBoxContainer = $Screen/CenterContainer/Content
@onready var day_label: Label = $Screen/CenterContainer/Content/DayLabel
@onready var goal_label: Label = $Screen/CenterContainer/Content/GoalLabel


func _ready() -> void:
	night_overlay.modulate.a = 0.0
	content.modulate.a = 0.0
	hide()


func _input(_event: InputEvent) -> void:
	if visible:
		get_viewport().set_input_as_handled()


func cover(day_number: int, custom_title: String = "") -> void:
	night_overlay.modulate.a = 0.0
	content.modulate.a = 0.0
	goal_label.hide()
	goal_label.text = ""
	day_label.text = custom_title if not custom_title.is_empty() else "Jour %d" % day_number
	show()

	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		night_overlay,
		"modulate:a",
		1.0,
		fade_duration
	)

	await tween.finished


func reveal(target_money: int = -1) -> void:
	goal_label.visible = target_money >= 0
	goal_label.text = "Objectif : terminer avec au moins %d €" % target_money if target_money >= 0 else ""

	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		content,
		"modulate:a",
		1.0,
		text_fade_duration
	)

	tween.tween_interval(text_hold_duration)

	tween.tween_property(
		content,
		"modulate:a",
		0.0,
		text_fade_duration
	)

	tween.tween_property(
		night_overlay,
		"modulate:a",
		0.0,
		fade_duration
	)

	await tween.finished
	hide()
