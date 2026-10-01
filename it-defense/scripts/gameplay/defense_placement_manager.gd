extends Node2D

const SLOT_MASK: int = 1 << 3

var source_card: DefenseCard
var dragged_data: DefenseData
var preview: Sprite2D
var hovered_slot: DefenseSlot

var defense_slots_container: Node2D
var defense_container: Node2D

func setup_container(slots: Node2D, defenses: Node2D) -> void:
	defense_slots_container = slots
	defense_container = defenses

func start_drag(card: DefenseCard) -> void:
	# clean last drag data and preview
	cancel_drag()
	
	if card.is_empty():
		return
	
	source_card = card
	dragged_data = card.defense_data
	source_card.set_dragging(true)
	
	preview = Sprite2D.new()
	preview.texture = dragged_data.icon
	preview.z_index = 100
	add_child(preview)
	
	preview.global_position = get_global_mouse_position()


func cancel_drag() -> void:
	if is_instance_valid(preview):
		preview.queue_free()
	
	if is_instance_valid(source_card):
		source_card.set_dragging(false)
	
	preview = null
	source_card = null
	dragged_data = null
		

func _process(_delta: float) -> void:
	if is_instance_valid(preview):
		preview.global_position = get_global_mouse_position()

func _input(event: InputEvent) -> void:
	if not is_instance_valid(preview):
		return
	
	# mouse event
	if event is InputEventMouseButton:
		# left mouse button released
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			cancel_drag()
			get_viewport().set_input_as_handled()
			# Todo
			#Do the test to see if is possible to place
		
		# right mouse button released
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			cancel_drag()
			get_viewport().set_input_as_handled()

		
