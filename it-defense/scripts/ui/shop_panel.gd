class_name ShopPanel extends Control

@onready var close_button: Button = ($CenterContainer/WindowPanel/ButtonLayer/CloseButton)
@onready var product_grid: GridContainer = ($CenterContainer/WindowPanel/BookPadding/HBoxContainer/LeftPage/MarginContainer/Content/ProductScroll/ContentPadding/ProductGrid)

@onready var details: VBoxContainer = ($CenterContainer/WindowPanel/BookPadding/HBoxContainer/RightPage/MarginContainer/Details)
@onready var description_content: VBoxContainer = details.get_node("ScrollContainer/DescriptionPadding/VBoxContainer")

@onready var name_label: Label = description_content.get_node("NameLabel")
@onready var product_icon: TextureRect = description_content.get_node("ProductIcon")
@onready var description_label: Label = description_content.get_node("DescriptionLabel")
@onready var price_label: Label = description_content.get_node("PriceLabel")
@onready var buy_button: Button = details.get_node("BuyButton")


@export var shop_item_scene: PackedScene
@export var products: Array[DefenseData]

signal try_buy_defense(defense_data: DefenseData)


var product_group: ButtonGroup = ButtonGroup.new()

var selected_defense: DefenseData

func _ready() -> void:
	close_button.pressed.connect(_on_close_button_pressed)
	
	product_group.allow_unpress = false
	product_group.pressed.connect(_on_product_pressed)
	
	_fill_products()
	
	buy_button.pressed.connect(_on_buy_button_pressed)


# function to fill product grid
func _fill_products() -> void:
	var first_item: ShopItem = null
	
	for product in products:
		var item := shop_item_scene.instantiate() as ShopItem
		item.defense_data = product
		
		if product != null:
			item.toggle_mode = true
			item.button_group = product_group
			if first_item == null:
				first_item = item
			
		product_grid.add_child(item)
			
	buy_button.disabled = first_item == null
		
	if first_item != null:
		select_item(first_item)
	else:
		refresh_details()


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
