class_name ToastMessage extends CanvasLayer

const SLIDE_DISTANCE: float = 8.0

@onready var bubble: PanelContainer = $Bubble
@onready var title_label: Label = $Bubble/Content/TitleLabel
@onready var message_label: Label = $Bubble/Content/MessageLabel
@onready var hide_timer: Timer = $HideTimer
@onready var resting_y: float = bubble.position.y

var transition: Tween


func _ready() -> void:
	hide_timer.timeout.connect(_dismiss)
	bubble.minimum_size_changed.connect(_fit_bubble_height)


func _fit_bubble_height() -> void:
	bubble.size.y = bubble.get_combined_minimum_size().y


func clear_message() -> void:
	hide_timer.stop()
	if transition != null:
		transition.kill()
	bubble.hide()


func show_message(message: String, title: String = "Information") -> void:
	title_label.text = title
	message_label.text = message

	if not bubble.visible:
		bubble.modulate.a = 0.0
		bubble.position.y = resting_y - SLIDE_DISTANCE
		bubble.show()

	if transition != null:
		transition.kill()
	transition = create_tween().set_parallel().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	transition.tween_property(bubble, "modulate:a", 1.0, 0.20)
	transition.tween_property(bubble, "position:y", resting_y, 0.20)
	hide_timer.start()


func _dismiss() -> void:
	if transition != null:
		transition.kill()
	transition = create_tween().set_parallel().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	transition.tween_property(bubble, "modulate:a", 0.0, 0.25)
	transition.tween_property(bubble, "position:y", resting_y - SLIDE_DISTANCE, 0.25)
	transition.chain().tween_callback(bubble.hide)
