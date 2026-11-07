extends Node2D

const SLOT_MASK: int = 1 << 3 # lot collison layer mask = 4

@onready var drag_preview_layer: CanvasLayer = $DragPreviewLayer
@onready var selection_timer: Timer = $SelectionTimer


# signal to inform GameplayUI selection is changed, update action button for defense slot
signal selection_changed(slot: DefenseSlot)

var source_card: DefenseCard
var dragged_data: DefenseData
var preview: Sprite2D
var hovered_slot: DefenseSlot

var defense_slots_container: Node2D
var defense_container: Node2D

var placement_pending: bool = false
var release_position: Vector2
var release_over_ui: bool = false

var selected_slot: DefenseSlot

func _ready() -> void:
	selection_timer.timeout.connect(clear_selection)

# set container for defenses and slots
func setup_container(slots_container: Node2D, defenses_container: Node2D) -> void:
	defense_slots_container = slots_container
	defense_container = defenses_container
	
	# connect signals for every slot in container
	for child in defense_slots_container.get_children():
		var slot := child as DefenseSlot
		
		if slot == null:
			continue
		
		slot.slot_clicked.connect(select_one_slot)


func select_one_slot(slot: DefenseSlot) -> void:
	if not is_instance_valid(slot) or slot.is_available():
		clear_selection()
		return
	
	# cancel old selecttion
	if is_instance_valid(selected_slot):
		selected_slot.set_selected(false)
	
	# select new slot
	selected_slot = slot
	selected_slot.set_selected(true)
	
	# start cancal selection timer
	selection_timer.start()
	
	# release signal to gameplayui
	selection_changed.emit(slot)


func clear_selection() -> void:
	# stop timer
	selection_timer.stop()
	
	if is_instance_valid(selected_slot):
		selected_slot.set_selected(false)
	
	selected_slot = null
	selection_changed.emit(null)


func remove_selected_defense() -> void:
	if not is_instance_valid(selected_slot):
		return
	
	if selected_slot.is_available():
		clear_selection()
		return
	
	var defense := selected_slot.placed_defense
	defense.attack_timer.stop()
	selected_slot.placed_defense = null
	
	clear_selection()
	defense.queue_free()


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
	drag_preview_layer.add_child(preview)
	preview.global_position = preview.get_global_mouse_position()


func cancel_drag() -> void:
	clear_selection()
	
	placement_pending = false
	if is_instance_valid(preview):
		preview.queue_free()
	
	if is_instance_valid(source_card):
		source_card.set_dragging(false)
	
	preview = null
	source_card = null
	dragged_data = null
		

func _process(_delta: float) -> void:
	if is_instance_valid(preview):
		preview.global_position = preview.get_global_mouse_position()


func _physics_process(_delta: float) -> void:
	if not placement_pending:
		return
	
	placement_pending = false
	
	if not release_over_ui:
		var slot := find_avaliable_slot(release_position)
		if slot != null and slot.is_available():
			place_defense(slot)
	
	cancel_drag()


func _input(event: InputEvent) -> void:
	if not is_instance_valid(preview):
		return
	
	# mouse event
	if event is InputEventMouseButton:
		# left mouse button released
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			release_position = get_global_mouse_position()
			release_over_ui = (get_viewport().gui_get_hovered_control() != null)
			placement_pending = true
			get_viewport().set_input_as_handled()
		
		# right mouse button released
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			cancel_drag()
			get_viewport().set_input_as_handled()


func find_avaliable_slot(position: Vector2) -> DefenseSlot:
	var query := PhysicsPointQueryParameters2D.new()
	query.position = position
	query.collision_mask = SLOT_MASK
	query.collide_with_areas = true
	query.collide_with_bodies = false
	
	var hits := get_world_2d().direct_space_state.intersect_point(query)
	
	for hit in hits:
		var area := hit["collider"] as Area2D
		if area == null:
			continue

		var slot := area.get_parent() as DefenseSlot
		if slot != null and slot.get_parent() == defense_slots_container:
			return slot

	return null

func place_defense(slot: DefenseSlot) -> void:
	if not is_instance_valid(source_card) or dragged_data == null:
		return
	if dragged_data.scene == null:
		return
	
	var instance := dragged_data.scene.instantiate()
	if not instance is Node2D:
		instance.free()
		return
	
	var defense := instance as Defense
	
	defense.data = dragged_data
	
	defense.set("detection_areas", slot.detection_areas.duplicate())
	defense_container.add_child(defense)
	defense.global_position = slot.global_position
	
	slot.placed_defense = defense
	#source_card.set_card(null)
	source_card.take_one_card(dragged_data)
	
	
	
