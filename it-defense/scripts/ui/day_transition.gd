class_name DayTransition
extends CanvasLayer

@export_range(0.05, 3.0) var fade_duration: float = 0.8
@export_range(0.05, 1.0) var text_fade_duration: float = 0.2
@export_range(0.05, 3.0) var text_hold_duration: float = 0.8

@onready var night_overlay: ColorRect = $Screen/NightOverlay
@onready var day_label: Label = $Screen/CenterContainer/DayLabel


func _ready() -> void:
	night_overlay.modulate.a = 0.0
	day_label.modulate.a = 0.0
	hide()


func _input(_event: InputEvent) -> void:
	if visible:
		get_viewport().set_input_as_handled()


func cover(day_number: int) -> void:
	night_overlay.modulate.a = 0.0
	day_label.modulate.a = 0.0
	day_label.text = "Jour %d" % day_number
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

	tween.tween_property(
		day_label,
		"modulate:a",
		1.0,
		text_fade_duration
	)

	tween.tween_interval(text_hold_duration)

	await tween.finished


func reveal() -> void:
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		day_label,
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
