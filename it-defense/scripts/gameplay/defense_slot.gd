class_name DefenseSlot extends Node2D

# where the defense on this slot can attack
@export var detection_areas: Array[DangerDetectionArea] = []


@onready var border: Line2D = $Border	# highlight border when select this slot
@onready var area: Area2D = $Area2D	# collision area
@onready var action_menu_anchor: Marker2D = $ActionMenuAnchor	# where we show the action menu


# slot clicked signal to defense placement manager
signal slot_clicked(slot: DefenseSlot)


var placed_defense: Node2D

func _ready() -> void:
	area.input_event.connect(_on_area_clicked)
	
	# set border apperances
	border.points = PackedVector2Array([
		Vector2(-32, -32),
		Vector2(32, -32),
		Vector2(32, 32),
		Vector2(-32, 32)
	])
	border.closed = true
	border.width = 3.0
	border.default_color = Color(0.898, 0.655, 0.094, 1.0)
	border.hide()


func is_available() -> bool:
	return not is_instance_valid(placed_defense)


func set_selected(value: bool) -> void:
	border.visible = value


func _on_area_clicked(
	_viewport: Node,
	event: InputEvent,
	_shape_idx: int
) -> void:
	if not event is InputEventMouseButton:
		return
	
	if event.button_index != MOUSE_BUTTON_LEFT:
		return
	
	if not event.pressed:
		return
	
	# if no defense placed in this slot, no response for click
	if not is_instance_valid(placed_defense):
		return
	
	# only handle left mouse clicked event
	slot_clicked.emit(self)
	get_viewport().set_input_as_handled()
	
