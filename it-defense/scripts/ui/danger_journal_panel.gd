class_name DangerJournalPanel
extends Control

signal closed

@export var item_scene: PackedScene

@onready var danger_grid: GridContainer = %DangerGrid
@onready var name_label: Label = %NameLabel
@onready var danger_icon: TextureRect = %DangerIcon
@onready var description_label: Label = %DescriptionLabel
@onready var discovery_label: Label = %CountLabel
@onready var close_button: Button = %CloseButton

var item_group: ButtonGroup = ButtonGroup.new()


func _ready() -> void:
	hide()
	item_group.allow_unpress = false
	item_group.pressed.connect(_on_item_pressed)
	close_button.pressed.connect(close)


func open(entries: Array[DangerData]) -> void:
	for child in danger_grid.get_children():
		danger_grid.remove_child(child)
		child.queue_free()
		
	var first_item: DangerJournalItem = null
	
	for data in entries:
		var item := item_scene.instantiate() as DangerJournalItem
		item.danger_data = data
		item.button_group = item_group
		
		danger_grid.add_child(item)
		
		if first_item == null:
			first_item = item

	discovery_label.text = "Découvertes : %d" % entries.size()
	show()

	if first_item != null:
		first_item.button_pressed = true
		_show_details(first_item.danger_data)
		first_item.grab_focus()
	else:
		_show_details(null)
		close_button.grab_focus()


func _on_item_pressed(button: BaseButton) -> void:
	var item := button as DangerJournalItem

	if item != null:
		_show_details(item.danger_data)


func _show_details(data: DangerData) -> void:
	if data == null:
		name_label.text = "Aucune menace rencontrée"
		danger_icon.texture = null
		danger_icon.hide()
		description_label.text = ("Les menaces rencontrées apparaîtront ici.")
		return
		
	name_label.text = data.display_name
	danger_icon.texture = data.icon
	danger_icon.visible = data.icon != null
	description_label.text = data.description


func close() -> void:
	if not visible:
		return
		
	hide()
	
	# signal to game play ui
	closed.emit()
