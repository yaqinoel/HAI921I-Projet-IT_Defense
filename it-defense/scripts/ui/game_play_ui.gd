class_name GamePlayUI extends CanvasLayer

@export var test_defense: DefenseData

@onready var grid: GridContainer = ($Root/MarginContainer/DefensePanelContainer/GridContainer)
@onready var money_label: Label = $Root/MoneyLabel
@onready var shop_panel: ShopPanel = $Root/ShopPanel
@onready var shop_button: Button = $Root/ShopButton
@onready var message_popup: MessagePopup = $MessagePopup
@onready var toast_message: ToastMessage = $ToastMessage


signal defense_drag_started(card: DefenseCard)
signal purchase_requested(defense_data: DefenseData)

func _ready() -> void:
	for child in grid.get_children():
		var card := child as DefenseCard
		if card != null:
			card.drag_started.connect(_on_card_drag_started)
	
	shop_panel.hide()
	
	shop_button.pressed.connect(_on_shop_button_pressed)
	shop_panel.try_buy_defense.connect(_on_shop_purchase_requested)	


func _on_card_drag_started(card: DefenseCard) -> void:
	defense_drag_started.emit(card)


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
		# if there are a case has the same type defense, return it
		elif card.defense_data.type == data.type and card.can_put(data):
			return card 
		# over max count, we can not put more
		else:
			return null
	
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
	shop_panel.visible = not shop_panel.visible


func _on_shop_purchase_requested(defense_data: DefenseData) -> void:
	purchase_requested.emit(defense_data)
