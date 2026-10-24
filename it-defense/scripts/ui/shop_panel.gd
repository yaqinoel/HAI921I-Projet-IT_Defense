class_name ShopPanel extends Control

@onready var close_button: Button = ($CenterContainer/WindowPanel/ButtonLayer/CloseButton)
@onready var product_grid: GridContainer = ($CenterContainer/WindowPanel/BookPadding/HBoxContainer/LeftPage/MarginContainer/Content/ProductScroll/ContentPadding/ProductGrid)

@onready var details: VBoxContainer = ($CenterContainer/WindowPanel/BookPadding/HBoxContainer/RightPage/MarginContainer/Details)
@onready var description_content: VBoxContainer = details.get_node("ScrollContainer/DescriptionPadding/VBoxContainer")

@onready var name_label: Label = description_content.get_node("NameLabel")
@onready var product_icon: TextureRect = description_content.get_node("ProductIcon")
@onready var description_label: Label = description_content.get_node("DescriptionLabel")
@onready var price_label: Label = description_content.get_node("PriceLabel")
@onready var but_button: Button = details.get_node("BuyButton")


signal try_buy_defense(defense_data: DefenseData)


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
	
	but_button.pressed.connect(_on_buy_button_pressed)


func _on_close_button_pressed() -> void:
	hide()


func _on_product_pressed(button: BaseButton) -> void:
	select_item(button as ShopItem)


func select_item(item: ShopItem) -> void:
	if item == null or item.disabled or item.defense_data == null:
		return

	item.button_pressed = true

	selected_defense = item.defense_data
	refresh_details()


func refresh_details() -> void:
	if selected_defense == null:
		name_label.text = "Aucune défense disponible"
		product_icon.texture = null
		product_icon.hide()
		description_label.text = ""
		price_label.text = ""
		return

	name_label.text = "Name : " + str(selected_defense.display_name)

	product_icon.texture = selected_defense.icon
	product_icon.show()

	description_label.text = selected_defense.description

	price_label.text = "Prix : " + str(selected_defense.cost) + " €"


func _on_buy_button_pressed() -> void:
	if selected_defense == null:
		return
		
	try_buy_defense.emit(selected_defense)
