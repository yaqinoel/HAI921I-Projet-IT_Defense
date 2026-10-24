extends CanvasLayer

@export var test_defense: DefenseData

@onready var grid: GridContainer = ($Root/MarginContainer/DefensePanelContainer/GridContainer)
@onready var money_label: Label = $Root/MoneyLabel
@onready var shop_panel: Control = $Root/ShopPanel
@onready var shop_button: Button = $Root/ShopButton


signal defense_drag_started(card: DefenseCard)

func _ready() -> void:
	for child in grid.get_children():
		var card := child as DefenseCard
		if card != null:
			card.drag_started.connect(_on_card_drag_started)
	
	shop_panel.hide()
	
	shop_button.pressed.connect(_on_shop_button_pressed)


func _on_card_drag_started(card: DefenseCard) -> void:
	defense_drag_started.emit(card)


func find_empty_card() -> DefenseCard:
	for child in grid.get_children():
		var card :=  child as DefenseCard
		if card != null and card.is_empty():
			return card
	return null


func _input(event: InputEvent) -> void:
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

		KEY_P:
			add_test_card()
			get_viewport().set_input_as_handled()


func add_test_card() -> void:
	if test_defense == null:
		print("please set Test Defense")
		return

	var card := find_empty_card()
	if card == null:
		print("No place for new card")
		return

	card.set_card(test_defense)


func update_money(value: int) -> void:
	money_label.text = str(value) + " €"


func _on_shop_button_pressed() -> void:
	shop_panel.visible = not shop_panel.visible
