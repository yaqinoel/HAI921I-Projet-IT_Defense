class_name ShopItem extends Button

@export var defense_data: DefenseData

@onready var selection_frame: TextureRect = $SelectionFrame
@onready var defense_icon: TextureRect = $CenterContainer/Icon


func _ready() -> void:
	toggled.connect(_on_toggled)
	selection_frame.visible = button_pressed
	if defense_data == null:
		disabled = true
	else:
		disabled = false
		defense_icon.texture = defense_data.icon


func _on_toggled(is_selected: bool) -> void:
	selection_frame.visible = is_selected


func set_content(content_data: DefenseData) -> void:
	defense_data = content_data
	disabled = false
	defense_icon.texture = defense_data.icon
	
