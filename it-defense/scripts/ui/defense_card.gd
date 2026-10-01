class_name DefenseCard extends Control

var defense_data: DefenseData = null
var is_dragging: bool = false

signal drag_started(card: DefenseCard)


func _ready() -> void:
	refresh_state()


func refresh_state() -> void:
	$Icon.visible = defense_data != null and not is_dragging
	$Icon.texture = defense_data.icon if defense_data != null else null


func set_dragging(value: bool) -> void:
	is_dragging = value
	refresh_state()


func is_empty() -> bool:
	return defense_data == null


func set_card(data: DefenseData) -> void:
	defense_data = data
	is_dragging = false
	refresh_state()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if not is_empty() and not is_dragging:
				drag_started.emit(self)
				accept_event()
