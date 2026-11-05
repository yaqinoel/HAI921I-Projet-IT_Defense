class_name DefenseCard extends Control


const MAX_COUNT: int = 10	# max defense number in this case
var count: int = 0	# current defense card in this case

var defense_data: DefenseData = null
var is_dragging: bool = false

signal drag_started(card: DefenseCard)


func _ready() -> void:
	refresh_state()


# to see if we can put this kind of defense in this case
func can_put(data: DefenseData) -> bool:
	if data == null or count >= MAX_COUNT:
		return false
	return is_empty() or defense_data.type == data.type


func refresh_state() -> void:
	$Icon.visible = defense_data != null and not is_dragging
	$Icon.texture = defense_data.icon if defense_data != null else null
	$CountLabel.text = str(count) if count > 0 else ""


func set_dragging(value: bool) -> void:
	is_dragging = value
	refresh_state()


func is_empty() -> bool:
	return count == 0


func clear_card() -> void:
	count = 0
	defense_data = null
	is_dragging = false
	refresh_state()


# add one defense card in this case
func add_card(data: DefenseData) -> void:
	if not can_put(data):
		return
	
	if is_empty():
		defense_data = data
	
	count += 1
	refresh_state()


# take one defense card from this card
func take_one_card(data: DefenseData) -> void:
	if is_empty() or data == null:
		return
	count -= 1
	
	if defense_data.type != data.type:
		return
	
	if is_empty():
		defense_data = null
		
	is_dragging = false
	refresh_state()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if not is_empty() and not is_dragging:
				drag_started.emit(self)
				accept_event()
