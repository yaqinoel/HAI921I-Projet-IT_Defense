extends Control

@onready var close_button: Button = ($CenterContainer/WindowPanel/ButtonLayer/CloseButton)
@onready var product_grid: GridContainer = ($CenterContainer/WindowPanel/BookPadding/HBoxContainer/LeftPage/MarginContainer/Content/ProductScroll/ContentPadding/ProductGrid)

var product_group: ButtonGroup = ButtonGroup.new()

var selected_defense: DefenseData

func _ready() -> void:
	close_button.pressed.connect(_on_close_button_pressed)
	
	product_group.allow_unpress = false
	product_group.pressed.connect(_on_product_pressed)
	
	for child in product_grid.get_children():
		var item := child as ShopItem
		if item == null:
			continue

		item.toggle_mode = true
		item.button_group = product_group


func _on_close_button_pressed() -> void:
	hide()


func _on_product_pressed(button: BaseButton) -> void:
	var item := button as ShopItem
	if item == null or item.defense_data == null:
		return

	selected_defense = item.defense_data
	
	# TODO refresh defense information
