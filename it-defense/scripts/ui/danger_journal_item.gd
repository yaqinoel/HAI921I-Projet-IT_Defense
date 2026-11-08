class_name DangerJournalItem
extends Button

@export var danger_data: DangerData

@onready var danger_icon: TextureRect = $CenterContainer/Icon
@onready var selection_frame: TextureRect = $SelectionFrame


func _ready() -> void:
	toggle_mode = true
	toggled.connect(_on_toggled)

	disabled = danger_data == null
	danger_icon.texture = danger_data.icon if danger_data != null else null
	selection_frame.visible = button_pressed


func _on_toggled(is_selected: bool) -> void:
	selection_frame.visible = is_selected
