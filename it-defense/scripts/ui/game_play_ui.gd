class_name GamePlayUI extends CanvasLayer

@export var test_defense: DefenseData

@onready var grid: GridContainer = ($Root/MarginContainer/DefensePanelContainer/GridContainer)
@onready var root: Control = $Root
@onready var top_right: HBoxContainer = $Root/TopRight
@onready var money_label: Label = $Root/TopRight/Balance/Content/MoneyLabel
@onready var shop_panel: ShopPanel = $Root/ShopPanel
@onready var shop_button: Button = $Root/TopRight/ShopButton
@onready var pause_button: Button = $Root/TopRight/PauseButton
@onready var settings_button: Button = $Root/TopRight/SettingsButton
@onready var message_popup: MessagePopup = $MessagePopup
@onready var toast_message: ToastMessage = $ToastMessage

@onready var defense_slot_actions: PanelContainer = $Root/DefenseSlotActionMenu
@onready var remove_defense_button: Button = defense_slot_actions.get_node("Padding/ActionButtons/RemoveButton")
@onready var defense_info_button: Button = defense_slot_actions.get_node("Padding/ActionButtons/InfoButton")


signal defense_drag_started(card: DefenseCard)
signal purchase_requested(defense_data: DefenseData)
signal pause_requested
signal settings_requested
signal defense_remove_requested

var interaction_blocked: bool = false
var previous_process_mode: ProcessMode
var previous_popup_process_mode: ProcessMode
var selectd_display_slot: DefenseSlot	# the slot that we want to show action menu

func _ready() -> void:
	for child in grid.get_children():
		var card := child as DefenseCard
		if card != null:
			card.drag_started.connect(_on_card_drag_started)
	
	shop_panel.hide()
	shop_button.pressed.connect(_on_shop_button_pressed)
	shop_panel.try_buy_defense.connect(_on_shop_purchase_requested)
	
	defense_slot_actions.hide()
	remove_defense_button.pressed.connect(defense_remove_requested.emit)
	defense_info_button.pressed.connect(_on_defense_info_pressed)
	
	pause_button.pressed.connect(pause_requested.emit)
	settings_button.pressed.connect(settings_requested.emit)
	root.resized.connect(_fit_hud)
	top_right.resized.connect(_fit_hud)
	_fit_hud()


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
	if interaction_blocked == value:
		return
	interaction_blocked = value
	if value:
		previous_process_mode = process_mode
		previous_popup_process_mode = message_popup.process_mode
		message_popup.process_mode = Node.PROCESS_MODE_DISABLED
		process_mode = Node.PROCESS_MODE_DISABLED
	else:
		process_mode = previous_process_mode
		message_popup.process_mode = previous_popup_process_mode


func reset_for_new_run() -> void:
	shop_panel.hide()
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


func _input(event: InputEvent) -> void:
	if message_popup.is_open():
		return

	if not event is InputEventKey:
		return

	if not event.pressed or event.echo:
		return

	match event.physical_keycode:
		KEY_B:
			shop_panel.visible = not shop_panel.visible
			get_viewport().set_input_as_handled()

		KEY_ESCAPE:
			if shop_panel.visible:
				shop_panel.hide()
				get_viewport().set_input_as_handled()


func update_money(value: int) -> void:
	money_label.text = str(value) + " €"


func show_message(message: String, title: String = "Information") -> void:
	message_popup.show_message(message, title)


func show_toast(message: String, title: String = "Information") -> void:
	toast_message.show_message(message, title)


func _on_shop_button_pressed() -> void:
	if interaction_blocked:
		return
	shop_panel.visible = not shop_panel.visible


func _on_shop_purchase_requested(defense_data: DefenseData) -> void:
	if interaction_blocked:
		return
	purchase_requested.emit(defense_data)


func show_defense_slot_actions(slot: DefenseSlot) -> void:
	if not is_instance_valid(slot) or slot.is_available():
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
	
