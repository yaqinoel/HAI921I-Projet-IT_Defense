class_name SystemMenu extends CanvasLayer

signal resume_requested
signal settings_back_requested
signal restart_requested
signal return_to_menu_requested

@onready var pages: VBoxContainer = $Screen/CenterContainer/Window/Padding/Pages
@onready var pause_page: VBoxContainer = pages.get_node("PausePage")
@onready var settings_page: VBoxContainer = pages.get_node("SettingsPage")
@onready var resume_button: Button = pause_page.get_node("ResumeButton")
@onready var volume_slider: HSlider = settings_page.get_node("AudioPanel/AudioContent/VolumeSlider")
@onready var volume_value: Label = settings_page.get_node("AudioPanel/AudioContent/VolumeHeading/VolumeValue")


func _ready() -> void:
	hide()	# hide this page by default
	
	# connect signals for buttons and slider
	resume_button.pressed.connect(resume_requested.emit)
	pause_page.get_node("RestartButton").pressed.connect(restart_requested.emit)
	pause_page.get_node("ReturnMenuButton").pressed.connect(return_to_menu_requested.emit)
	settings_page.get_node("BackButton").pressed.connect(settings_back_requested.emit)
	volume_slider.value_changed.connect(_on_volume_changed)


func show_pause() -> void:
	settings_page.hide()
	pause_page.show()
	show()	# show system menu ui
	resume_button.grab_focus()


func show_settings() -> void:
	var volume := db_to_linear(AudioServer.get_bus_volume_db(0)) * 100.0
	if AudioServer.is_bus_mute(0):
		volume = 0.0
	volume_slider.set_value_no_signal(volume)
	volume_value.text = "%d %%" % roundi(volume)
	pause_page.hide()
	settings_page.show()
	show()
	volume_slider.grab_focus()


func _on_volume_changed(value: float) -> void:
	volume_value.text = "%d %%" % roundi(value)
	AudioServer.set_bus_mute(0, is_zero_approx(value))
	if value > 0.0:
		AudioServer.set_bus_volume_db(0, linear_to_db(value / 100.0))
