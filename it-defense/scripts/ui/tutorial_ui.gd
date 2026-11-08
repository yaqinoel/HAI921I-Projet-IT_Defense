class_name TutorialUI extends CanvasLayer

signal next_requested
signal skip_requested

@onready var screen: Control = $Screen
@onready var shade: ColorRect = $Screen/Shade
@onready var hint_panel: PanelContainer = $Screen/HintPanel
@onready var focus_frame: Panel = $Screen/FocusFrame
@onready var progress_label: Label = $Screen/HintPanel/Content/ProgressLabel
@onready var title_label: Label = $Screen/HintPanel/Content/TitleLabel
@onready var description_label: Label = $Screen/HintPanel/Content/DescriptionLabel
@onready var next_button: Button = $Screen/HintPanel/Content/Buttons/NextButton
@onready var skip_button: Button = $Screen/HintPanel/Content/Buttons/SkipButton

var focus_target: CanvasItem
var world_focus_size: Vector2 = Vector2(90, 90)


func _ready() -> void:
	next_button.pressed.connect(next_requested.emit)
	skip_button.pressed.connect(skip_requested.emit)
	hide()
	screen.resized.connect(_fit_panel)


func show_hint(
	title: String,
	description: String,
	blocking: bool = true,
	show_next: bool = true
) -> void:
	title_label.text = title
	description_label.text = description
	shade.visible = blocking
	next_button.visible = show_next
	
	screen.mouse_filter = (
		Control.MOUSE_FILTER_STOP
		if blocking
		else Control.MOUSE_FILTER_IGNORE
	)
	show()
	_fit_panel()
	if show_next:
		next_button.grab_focus()


func set_step_details(step: int, total: int, next_text: String) -> void:
	progress_label.text = "FORMATION · %02d / %02d" % [step, total]
	next_button.text = next_text
	_fit_panel()


func set_focus_target(target: CanvasItem, world_size: Vector2 = Vector2(90, 90)) -> void:
	focus_target = target
	world_focus_size = world_size
	_update_focus()
	_fit_panel()


func _process(_delta: float) -> void:
	if visible:
		_update_focus()
		_fit_panel()


func _update_focus() -> void:
	focus_frame.hide()
	if not is_instance_valid(focus_target) or not focus_target.is_visible_in_tree():
		return
	var bounds := Rect2(-world_focus_size / 2.0, world_focus_size)
	var transform := focus_target.get_global_transform_with_canvas()
	if focus_target is Control:
		bounds = Rect2(Vector2.ZERO, focus_target.size)
	else:
		transform = Transform2D(0.0, transform.origin)
	var local_rect := screen.get_global_transform_with_canvas().affine_inverse() * (transform * bounds)
	local_rect = local_rect.grow(6.0)
	focus_frame.position = local_rect.position
	focus_frame.size = local_rect.size
	focus_frame.show()


func _fit_panel() -> void:
	if not is_node_ready():
		return
	hint_panel.custom_minimum_size.x = minf(400.0, maxf(1.0, screen.size.x - 32.0))
	hint_panel.reset_size()
	var corner := screen.size - hint_panel.size - Vector2(16, 16)
	var panel_position := Vector2(maxf(16.0, corner.x), maxf(16.0, corner.y))
	if focus_frame.visible and Rect2(panel_position, hint_panel.size).intersects(focus_frame.get_rect()):
		panel_position.x = 16.0
		if Rect2(panel_position, hint_panel.size).intersects(focus_frame.get_rect()):
			panel_position = Vector2(maxf(16.0, corner.x), 100.0)
	hint_panel.position = panel_position
