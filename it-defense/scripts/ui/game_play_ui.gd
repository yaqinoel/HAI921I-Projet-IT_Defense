extends CanvasLayer

@export var test_defense: DefenseData

@onready var grid: GridContainer = ($Root/MarginContainer/DefensePanelContainer/GridContainer)

signal defense_drag_started(card: DefenseCard)

func _ready() -> void:
	for child in grid.get_children():
		var card := child as DefenseCard
		if card != null:
			card.drag_started.connect(_on_card_drag_started)


func _on_card_drag_started(card: DefenseCard) -> void:
	defense_drag_started.emit(card)


func find_empty_card() -> DefenseCard:
	for child in grid.get_children():
		var card :=  child as DefenseCard
		if card != null and card.is_empty():
			return card
	return null


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and not event.echo:
			if event.physical_keycode == KEY_P:
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
