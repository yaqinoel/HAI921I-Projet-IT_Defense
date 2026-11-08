class_name GamePlayUI extends CanvasLayer

@export var test_defense: DefenseData

@onready var grid: GridContainer = ($Root/MarginContainer/DefensePanelContainer/GridContainer)
@onready var root: Control = $Root
@onready var top_right: HBoxContainer = $Root/TopRight
@onready var money_label: Label = $Root/TopRight/Balance/Content/MoneyLabel
@onready var shop_panel: ShopPanel = $Root/ShopPanel
@onready var shop_button: Button = $Root/TopRight/ShopButton
@onready var system_controls_layer: CanvasLayer = $SystemControlsLayer
@onready var pause_button: Button = $SystemControlsLayer/Root/Buttons/PauseButton
@onready var settings_button: Button = $SystemControlsLayer/Root/Buttons/SettingsButton
@onready var message_popup: MessagePopup = $MessagePopup
@onready var toast_message: ToastMessage = $ToastMessage

@onready var defense_slot_actions: PanelContainer = $Root/DefenseSlotActionMenu
@onready var remove_defense_button: Button = defense_slot_actions.get_node("Padding/ActionButtons/RemoveButton")
@onready var defense_info_button: Button = defense_slot_actions.get_node("Padding/ActionButtons/InfoButton")

@onready var journal_button: Button = $Root/TopRight/DangerJournalButton
@onready var danger_journal_panel: DangerJournalPanel = $Root/DangerJournalPanel

signal defense_drag_started(card: DefenseCard)
signal purchase_requested(defense_data: DefenseData)
signal pause_requested
signal settings_requested
signal defense_remove_requested
signal shop_requested
signal message_requested(message: String, title: String)
signal journal_requested

var interaction_blocked: bool = false
var content_window_open: bool = false
var selectd_display_slot: DefenseSlot	# the slot that we want to show action menu

func _ready() -> void:
	for child in grid.get_children():
		var card := child as DefenseCard
		if card != null:
			card.drag_started.connect(_on_card_drag_started)
			card.contents_changed.connect(_update_shop_capacity)
	
	shop_panel.hide()
	shop_button.pressed.connect(_on_shop_button_pressed)
	shop_panel.try_buy_defense.connect(_on_shop_purchase_requested)
	shop_panel.selection_changed.connect(_update_shop_capacity)
	shop_panel.visibility_changed.connect(_update_shop_capacity)
	
	danger_journal_panel.hide()
	journal_button.pressed.connect(_on_journal_button_pressed)
	
	defense_slot_actions.hide()
	remove_defense_button.pressed.connect(defense_remove_requested.emit)
	defense_info_button.pressed.connect(_on_defense_info_pressed)
	
	pause_button.pressed.connect(pause_requested.emit)
	settings_button.pressed.connect(settings_requested.emit)
	root.resized.connect(_fit_hud)
	top_right.resized.connect(_fit_hud)
	visibility_changed.connect(_sync_system_controls_visibility)
	_sync_system_controls_visibility()
	_fit_hud()
	_update_shop_capacity()


func _on_card_drag_started(card: DefenseCard) -> void:
	if interaction_blocked or get_tree().paused:
		return
	defense_drag_started.emit(card)


func _fit_hud() -> void:
	var card := grid.get_child(0) as Control
	var gap := grid.get_theme_constant("h_separation")
	var available_width := root.size.x - top_right.size.x - 64.0
	var card_width := card.get_combined_minimum_size().x
	var columns := floori((available_width + gap) / (card_width + gap))
	grid.columns = clampi(columns, 1, grid.get_child_count())


# if we alreay opened the system menu, we can not click gameplay ui
func set_gameplay_ui_blocked(value: bool) -> void:
	interaction_blocked = value
	_refresh_input_permissions()


func set_content_window_open(value: bool) -> void:
	content_window_open = value
	_refresh_input_permissions()


func _refresh_input_permissions() -> void:
	var gameplay_blocked := interaction_blocked or content_window_open
	grid.process_mode = Node.PROCESS_MODE_DISABLED if gameplay_blocked else Node.PROCESS_MODE_INHERIT
	shop_button.disabled = gameplay_blocked
	defense_slot_actions.process_mode = Node.PROCESS_MODE_DISABLED if gameplay_blocked else Node.PROCESS_MODE_INHERIT
	
	if gameplay_blocked:
		defense_slot_actions.hide()
		
	pause_button.disabled = interaction_blocked
	settings_button.disabled = interaction_blocked
	shop_panel.process_mode = Node.PROCESS_MODE_DISABLED if interaction_blocked else Node.PROCESS_MODE_INHERIT
	message_popup.process_mode = Node.PROCESS_MODE_DISABLED if interaction_blocked else Node.PROCESS_MODE_ALWAYS
	
	journal_button.disabled = gameplay_blocked
	danger_journal_panel.process_mode = (
		Node.PROCESS_MODE_DISABLED
		if interaction_blocked
		else Node.PROCESS_MODE_INHERIT
	)


func _sync_system_controls_visibility() -> void:
	system_controls_layer.visible = visible


func reset_for_new_run() -> void:
	shop_panel.close()
	message_popup.close()
	toast_message.clear_message()
	for child in grid.get_children():
		var card := child as DefenseCard
		if card != null:
			card.clear_card()


# find a avaliable card by defese
func find_avaliable_card(data: DefenseData) -> DefenseCard:
	if data == null:
		return null
	
	# keep the first empty card
	var first_empty_card: DefenseCard = null
	
	for child in grid.get_children():
		var card :=  child as DefenseCard
		if card == null:
			continue
		if card.is_empty():
			if first_empty_card == null:
				first_empty_card = card
		# if there are a case has the same type defense
		elif card.defense_data.type == data.type:
			# if over max count return null
			return card if card.can_put(data) else null
	
	# if there are no case has the same type defense, return first empty card
	return first_empty_card


func get_remaining_capacity(data: DefenseData) -> int:
	var card := find_avaliable_card(data)
	if card == null:
		return 0
	return maxi(0, DefenseCard.MAX_COUNT - card.count)


func _update_shop_capacity() -> void:
	var remaining := get_remaining_capacity(shop_panel.selected_defense)
	shop_panel.update_capacity(remaining)


func _input(event: InputEvent) -> void:
	if interaction_blocked or message_popup.is_open():
		return

	if not event is InputEventKey:
		return

	if not event.pressed or event.echo:
		return

	match event.physical_keycode:
		KEY_B:
			_on_shop_button_pressed()
			get_viewport().set_input_as_handled()

		KEY_ESCAPE:
			if shop_panel.visible:
				shop_panel.close()
				get_viewport().set_input_as_handled()


func update_money(value: int) -> void:
	money_label.text = str(value) + " €"


func show_message(message: String, title: String = "Information") -> void:
	if not interaction_blocked:
		message_requested.emit(message, title)


func show_toast(message: String, title: String = "Information") -> void:
	toast_message.show_message(message, title)


func _on_shop_button_pressed() -> void:
	if interaction_blocked or content_window_open:
		return
	shop_requested.emit()


func _on_shop_purchase_requested(defense_data: DefenseData) -> void:
	if interaction_blocked or not shop_panel.visible:
		return
	purchase_requested.emit(defense_data)


func show_defense_slot_actions(slot: DefenseSlot) -> void:
	if interaction_blocked or content_window_open or not is_instance_valid(slot) or slot.is_available():
		selectd_display_slot = null
		defense_slot_actions.hide()
		return
		
	selectd_display_slot = slot
	
	# change anchor position from game to screen space
	var screen_position := (
		slot.action_menu_anchor.get_global_transform_with_canvas().origin
	)
	
	defense_slot_actions.reset_size()
	var menu_position := (
		root.get_global_transform_with_canvas().affine_inverse()
		* screen_position
	)
	var maximum_position := root.size - defense_slot_actions.size - Vector2(8, 8)
	defense_slot_actions.position = Vector2(
		clampf(menu_position.x, 8.0, maxf(8.0, maximum_position.x)),
		clampf(menu_position.y, 8.0, maxf(8.0, maximum_position.y))
	)
	
	defense_slot_actions.show()


func _on_defense_info_pressed() -> void:
	if not is_instance_valid(selectd_display_slot):
		return
	
	var defense := selectd_display_slot.placed_defense as Defense

	if not is_instance_valid(defense) or defense.data == null:
		return

	show_message(
		defense.data.description,
		defense.data.display_name
	)


func _on_journal_button_pressed() -> void:
	if interaction_blocked or content_window_open:
		return
	journal_requested.emit()
