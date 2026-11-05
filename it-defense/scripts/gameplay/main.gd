extends Node2D

@onready var level_container: Node2D = $LevelContainer
@onready var defense_placement_manager = $DefensePlacementManager

@onready var game_session: GameSession = $GameSession
@onready var gameplay_ui: GamePlayUI = $GamePlayUI

@onready var camera: Camera2D = $Camera2D

# main menu references
@onready var menu_layer: CanvasLayer = $CanvasLayer
@onready var play_button: Button = $CanvasLayer/MainMenu/LeftPanel/Padding/HomePage/MenuButtons/PlayButton

var current_level: Node2D

@export var levels: Array[PackedScene] = []
var current_level_index: int = 0


func _ready():
	if levels.is_empty():
		push_error("Aucun niveau n'a été ajouté dans la liste levels.")
		return
	current_level_index = 0
	change_level(levels[current_level_index])
	game_session.money_changed.connect(gameplay_ui.update_money)

	gameplay_ui.update_money(game_session.money)

	gameplay_ui.defense_drag_started.connect(defense_placement_manager.start_drag)
	gameplay_ui.purchase_requested.connect(_on_purchase_requested)
	
	# move camera to menu view when game start
	var menu_view := current_level.get_node("CameraViews/MenuView") as Marker2D
	camera.global_position = menu_view.global_position
	
	#
	play_button.pressed.connect(_on_play_pressed)
	gameplay_ui.hide()
	get_tree().paused = true


func _on_play_pressed() -> void:
	var gameplay_view := current_level.get_node("CameraViews/GameplayView") as Marker2D
	camera.global_position = gameplay_view.global_position
	camera.force_update_scroll()

	menu_layer.hide()
	gameplay_ui.show()
	game_session.running = true
	get_tree().paused = false


func change_level(scene: PackedScene) -> void:
	var instance := scene.instantiate()
	if not instance is Node2D:
		instance.free()
		push_error("Root node of a level must be Node2D")
		return
	
	var next_level = instance as Node2D
	var slots := next_level.get_node_or_null("DefenseSlotContainer") as Node2D
	var defenses := next_level.get_node_or_null("DefenseContainer") as Node2D
	
	if slots == null or defenses == null:
		next_level.free()
		push_error("There is no slots or defenses for new level")
		return
	
	# clean old level
	if is_instance_valid(current_level):
		level_container.remove_child(current_level)
		current_level.queue_free()
	
	current_level = next_level
	level_container.add_child(current_level)
	
	# pass defense deplacement slot container and defenses container to  defense_placement_manager
	defense_placement_manager.setup_container(slots, defenses)
	
	var stations := current_level.get_node("WorkStations") as Node2D
	game_session.setup_workstations(stations)
	var spawner = current_level.get_node("DangerSpawner")
	spawner.level_won.connect(load_next_level)
	
func load_next_level() -> void:
	current_level_index += 1

	if current_level_index >= levels.size():
		print("Félicitations ! Tous les niveaux sont terminés.")
		return
	game_session.reset_session()
	change_level(levels[current_level_index])


func _on_purchase_requested(defense_data: DefenseData) -> void:
	if defense_data == null:
		return

	var card := gameplay_ui.find_avaliable_card(defense_data)

	if card == null:
		gameplay_ui.show_toast(
			"No place for new defense.",
			"Purchase failed"
		)
		return

	if not game_session.try_spend_money(defense_data.cost):
		gameplay_ui.show_toast(
			"Not enough money.\nPrice: %d €\nBalance: %d €" % [defense_data.cost, game_session.money],
			"Purchase failed"
		)
		return

	card.add_card(defense_data)

	print("purchase successed", defense_data.display_name)
