extends Control

signal about_requested

@onready var home_page: VBoxContainer = $LeftPanel/Padding/HomePage
@onready var about_page: VBoxContainer = $LeftPanel/Padding/AboutPage
@onready var about_button: Button = $LeftPanel/Padding/HomePage/MenuButtons/AboutButton
@onready var back_button: Button = $LeftPanel/Padding/AboutPage/BackButton
@onready var about_scroll: ScrollContainer = $LeftPanel/Padding/AboutPage/InformationScroll
@onready var credits_label: RichTextLabel = $LeftPanel/Padding/AboutPage/InformationScroll/Content/CreditsLabel


func _ready() -> void:
	about_button.pressed.connect(about_requested.emit)
	back_button.pressed.connect(show_home)
	credits_label.meta_clicked.connect(_open_credit_link)
	about_page.hide()
	home_page.show()


func show_about() -> void:
	home_page.hide()
	about_page.show()
	about_scroll.scroll_vertical = 0
	back_button.grab_focus()


func show_home() -> void:
	about_page.hide()
	home_page.show()
	about_button.grab_focus()


func _open_credit_link(meta: Variant) -> void:
	var url := str(meta)
	if url.begins_with("https://"):
		OS.shell_open(url)
