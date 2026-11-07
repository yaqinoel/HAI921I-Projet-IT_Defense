class_name StatusFeedback
extends Node2D

@onready var row: HBoxContainer = $HBoxContainer
@onready var icon: TextureRect = $HBoxContainer/Icon
@onready var text_label: Label = $HBoxContainer/Text

var animation: Tween


func _ready() -> void:
	hide()


func show_feedback(
	icon_texture: Texture2D,
	message: String,
	duration: float = 0.7,
	text_color: Color = Color.WHITE
) -> void:
	clear_feedback()

	icon.texture = icon_texture
	icon.visible = icon_texture != null
	text_label.text = message
	text_label.modulate = text_color
	show()
	
	# if duration <= 0, we don't clear this feedback
	if duration <= 0.0:
		return

	animation = create_tween()

	animation.tween_property(
		row, "position:y", -6.0, 0.2
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	animation.tween_property(
		row, "position:y", -3.0, 0.15
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	animation.tween_interval(duration)
	animation.tween_property(self, "modulate:a", 0.0, 0.25)
	animation.tween_callback(hide)


func clear_feedback() -> void:
	if animation != null:
		animation.kill()
		animation = null

	hide()
	row.position = Vector2.ZERO
	modulate.a = 1.0
