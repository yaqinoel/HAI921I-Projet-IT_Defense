class_name MessagePopup extends CanvasLayer

signal closed

@onready var overlay: Control = $Overlay
@onready var panel: PanelContainer = $Overlay/CenterContainer/WindowPanel
@onready var title_label: Label = $Overlay/CenterContainer/WindowPanel/Page/Content/TitleLabel
@onready var message_scroll: ScrollContainer = $Overlay/CenterContainer/WindowPanel/Page/Content/MessageScroll
@onready var message_label: Label = $Overlay/CenterContainer/WindowPanel/Page/Content/MessageScroll/MessageLabel
@onready var confirm_button: Button = $Overlay/CenterContainer/WindowPanel/Page/Content/ConfirmButton

var previous_focus: Control


func _ready() -> void:
	confirm_button.pressed.connect(close)
	overlay.resized.connect(_fit_viewport)
	_fit_viewport()


func show_message(message: String, title: String = "Information", button_text: String = "OK") -> void:
	if not is_open():
		previous_focus = get_viewport().gui_get_focus_owner()
	title_label.text = title
	message_label.text = message
	confirm_button.text = button_text
	message_scroll.scroll_vertical = 0
	overlay.show()
	_fit_viewport()
	confirm_button.grab_focus()


func is_open() -> bool:
	return overlay.visible


func close() -> void:
	if not is_open():
		return
	overlay.hide()
	if is_instance_valid(previous_focus) and previous_focus.is_visible_in_tree():
		previous_focus.grab_focus()
	previous_focus = null
	closed.emit()


func _input(event: InputEvent) -> void:
	if not is_open():
		return

	if event is InputEventKey or event is InputEventJoypadButton or event is InputEventJoypadMotion:
		get_viewport().set_input_as_handled()


func _fit_viewport() -> void:
	panel.custom_minimum_size.x = maxf(1.0, minf(480.0, overlay.size.x - 32.0))
	message_scroll.custom_minimum_size.y = clampf(overlay.size.y - 200.0, 48.0, 120.0)
