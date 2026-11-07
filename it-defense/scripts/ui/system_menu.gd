class_name SystemMenu extends CanvasLayer

signal resume_requested
signal settings_back_requested
signal restart_requested
signal return_to_menu_requested
signal next_level_requested

const RESULT_SUCCESS_ICON = preload("res://assets/ui/TravelBookLite/Sprites/UI_TravelBook_IconTick01a.png")
const RESULT_FAILURE_ICON = preload("res://assets/ui/TravelBookLite/Sprites/UI_TravelBook_IconCross01a.png")
const RESULT_COMPLETE_ICON = preload("res://assets/ui/TravelBookLite/Sprites/UI_TravelBook_IconStar01a.png")

@onready var pages: VBoxContainer = $Screen/CenterContainer/Window/Padding/Pages
@onready var pause_page: VBoxContainer = pages.get_node("PausePage")
@onready var settings_page: VBoxContainer = pages.get_node("SettingsPage")
@onready var resume_button: Button = pause_page.get_node("ResumeButton")
@onready var volume_slider: HSlider = settings_page.get_node("AudioPanel/AudioContent/VolumeSlider")
@onready var volume_value: Label = settings_page.get_node("AudioPanel/AudioContent/VolumeHeading/VolumeValue")
@onready var result_page: VBoxContainer = pages.get_node("ResultPage")
@onready var result_title: Label = result_page.get_node("Header/TitleLabel")
@onready var result_icon: TextureRect = result_page.get_node("Header/Icon")
@onready var result_summary: Label = result_page.get_node("SummaryPanel/SummaryLabel")
@onready var result_next_button: Button = result_page.get_node("NextButton")
@onready var result_retry_button: Button = result_page.get_node("RetryButton")
@onready var result_menu_button: Button = result_page.get_node("MainMenuButton")
@onready var result_window: PanelContainer = $Screen/CenterContainer/Window
@onready var result_shade: ColorRect = $Screen/Shade

var result_transition: Tween


func _ready() -> void:
	hide()	# hide this page by default
	
	# connect signals for buttons and slider
	resume_button.pressed.connect(resume_requested.emit)
	pause_page.get_node("RestartButton").pressed.connect(restart_requested.emit)
	pause_page.get_node("ReturnMenuButton").pressed.connect(return_to_menu_requested.emit)
	settings_page.get_node("BackButton").pressed.connect(settings_back_requested.emit)
	volume_slider.value_changed.connect(_on_volume_changed)
	result_next_button.pressed.connect(_on_result_next_pressed)
	result_retry_button.pressed.connect(_on_result_retry_pressed)
	result_menu_button.pressed.connect(_on_result_menu_pressed)


func show_pause() -> void:
	_reset_transition()
	result_page.hide()
	settings_page.hide()
	pause_page.show()
	show()	# show system menu ui
	resume_button.grab_focus()


func show_settings() -> void:
	_reset_transition()
	result_page.hide()
	var volume := db_to_linear(AudioServer.get_bus_volume_db(0)) * 100.0
	if AudioServer.is_bus_mute(0):
		volume = 0.0
	volume_slider.set_value_no_signal(volume)
	volume_value.text = "%d %%" % roundi(volume)
	pause_page.hide()
	settings_page.show()
	show()
	volume_slider.grab_focus()


func show_result(won: bool, summary: String, has_next_level: bool) -> void:
	_reset_transition()
	pause_page.hide()
	settings_page.hide()
	if not won:
		result_title.text = "Défaite"
		result_icon.texture = RESULT_FAILURE_ICON
	elif has_next_level:
		result_title.text = "Victoire !"
		result_icon.texture = RESULT_SUCCESS_ICON
	else:
		result_title.text = "Toutes les missions\nterminées !"
		result_icon.texture = RESULT_COMPLETE_ICON
	result_summary.text = summary
	result_next_button.visible = won and has_next_level
	result_retry_button.text = "Rejouer ce niveau" if won else "Réessayer"
	result_retry_button.theme_type_variation = &"Button" if won else &"PrimaryButton"
	result_menu_button.theme_type_variation = &"PrimaryButton" if won and not has_next_level else &"ReturnMenuButton"
	_set_result_buttons_disabled(true)
	result_page.show()
	result_window.modulate.a = 0.0
	result_shade.modulate.a = 0.0
	show()
	result_transition = create_tween().set_parallel()
	result_transition.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	result_transition.set_trans(Tween.TRANS_SINE)
	result_transition.set_ease(Tween.EASE_OUT)
	result_transition.tween_property(result_window, "modulate:a", 1.0, 0.25)
	result_transition.tween_property(result_shade, "modulate:a", 1.0, 0.25)
	result_transition.chain().tween_callback(_on_result_transition_finished)


func close() -> void:
	_reset_transition()
	hide()


func _reset_transition() -> void:
	if result_transition != null:
		result_transition.kill()
		result_transition = null
	result_window.modulate.a = 1.0
	result_shade.modulate.a = 1.0


func _on_result_transition_finished() -> void:
	result_transition = null
	if not visible or not result_page.visible:
		return
	_set_result_buttons_disabled(false)
	if result_next_button.visible:
		result_next_button.grab_focus()
	elif result_retry_button.theme_type_variation == &"PrimaryButton":
		result_retry_button.grab_focus()
	else:
		result_menu_button.grab_focus()


func _set_result_buttons_disabled(value: bool) -> void:
	result_next_button.disabled = value
	result_retry_button.disabled = value
	result_menu_button.disabled = value


func _accept_result_action() -> bool:
	if not result_page.is_visible_in_tree() or result_transition != null:
		return false
	if result_retry_button.disabled:
		return false
	_set_result_buttons_disabled(true)
	return true


func _on_result_next_pressed() -> void:
	if result_next_button.visible and _accept_result_action():
		next_level_requested.emit()


func _on_result_retry_pressed() -> void:
	if _accept_result_action():
		restart_requested.emit()


func _on_result_menu_pressed() -> void:
	if _accept_result_action():
		return_to_menu_requested.emit()


func _on_volume_changed(value: float) -> void:
	volume_value.text = "%d %%" % roundi(value)
	AudioServer.set_bus_mute(0, is_zero_approx(value))
	if value > 0.0:
		AudioServer.set_bus_volume_db(0, linear_to_db(value / 100.0))
