extends Node2D

@onready var level_container: Node2D = $LevelContainer
@onready var defense_placement_manager = $DefensePlacementManager

@onready var game_session: GameSession = $GameSession
@onready var gameplay_ui: GamePlayUI = $GamePlayUI

@onready var camera: Camera2D = $Camera2D
@onready var system_menu: SystemMenu = $SystemMenu

# main menu references
@onready var menu_layer: CanvasLayer = $StartMenu
@onready var play_button: Button = $StartMenu/MainMenu/LeftPanel/Padding/HomePage/MenuButtons/PlayButton

var current_level: Node2D

@export var levels: Array[PackedScene] = []
var current_level_index: int = 0

# content winsows status (ex. shop, questionnaire...)
enum ContentWindow {
	NONE,
	SHOP,
	DANGER_INFO,
	QUESTIONNAIRE
}

# ui menu status (ex. pause, restart, settings, quit)
enum OverlayMenu {
	NONE,
	PAUSE,
	SETTINGS,
	RESTART,
	QUIT
}

var content_window: ContentWindow = ContentWindow.NONE
var overlay_menu: OverlayMenu = OverlayMenu.NONE
var paused_before_system_menu: bool = false
var previous_ui_focus: Control


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
	gameplay_ui.pause_requested.connect(_on_pause_requested)
	gameplay_ui.settings_requested.connect(_on_settings_requested)
	
	system_menu.resume_requested.connect(_close_system_menu)
	system_menu.settings_back_requested.connect(_on_settings_back)
	system_menu.restart_requested.connect(restart_level, CONNECT_DEFERRED)
	system_menu.return_to_menu_requested.connect(_on_return_to_menu_requested, CONNECT_DEFERRED)
	
	# move camera to menu view when game start
	var menu_view := current_level.get_node("CameraViews/MenuView") as Marker2D
	camera.global_position = menu_view.global_position
	
	play_button.pressed.connect(_on_play_pressed)
	gameplay_ui.hide()	# gameplay ui is hiden by default
	get_tree().paused = true	# pause the game


# when play button is pressed
func _on_play_pressed() -> void:
	
	# move camera to game view
	var gameplay_view := current_level.get_node("CameraViews/GameplayView") as Marker2D
	camera.global_position = gameplay_view.global_position
	camera.force_update_scroll()

	menu_layer.hide()	# hide start menu
	gameplay_ui.show()	# show HUD
	game_session.running = true
	get_tree().paused = false
	
	var spawner = current_level.get_node("DangerSpawner")
	spawner.start_game()

# when pause or settings request 
func _enter_system_menu(target: OverlayMenu) -> void:
	# first time into system menu from game
	if overlay_menu == OverlayMenu.NONE:
		paused_before_system_menu = get_tree().paused	# if the game is already paused before into system menu
		previous_ui_focus = get_viewport().gui_get_focus_owner()	# focus before
		defense_placement_manager.cancel_drag()
		gameplay_ui.set_gameplay_ui_blocked(true)
	
	# change system menu to target menu
	overlay_menu = target
	get_tree().paused = true


func _on_pause_requested() -> void:
	if overlay_menu != OverlayMenu.NONE or not gameplay_ui.visible:
		return
	_enter_system_menu(OverlayMenu.PAUSE)
	system_menu.show_pause()


func _on_settings_requested() -> void:
	if overlay_menu == OverlayMenu.SETTINGS or not gameplay_ui.visible:
		return
	_enter_system_menu(OverlayMenu.SETTINGS)
	system_menu.show_settings()


func _on_settings_back() -> void:
	if overlay_menu != OverlayMenu.SETTINGS:
		return
	_close_system_menu()


func _close_system_menu() -> void:
	if overlay_menu == OverlayMenu.NONE:
		return
	system_menu.hide()
	overlay_menu = OverlayMenu.NONE
	gameplay_ui.set_gameplay_ui_blocked(false)
	get_tree().paused = paused_before_system_menu
	
	# try to reset previous focus
	if (
		is_instance_valid(previous_ui_focus)
		and previous_ui_focus.is_visible_in_tree()
		and previous_ui_focus.can_process()
	):
		previous_ui_focus.grab_focus()
	previous_ui_focus = null


# go back to start menu
func _on_return_to_menu_requested() -> void:
	# clean or close everythings
	defense_placement_manager.cancel_drag()
	gameplay_ui.reset_for_new_run()
	game_session.reset_session()
	
	# change to first level (or we can just keep the same level
	current_level_index = 0
	change_level(levels[current_level_index])
	
	paused_before_system_menu = true
	_close_system_menu()
	content_window = ContentWindow.NONE
	gameplay_ui.hide()
	menu_layer.show()
	
	# move camera to menu view
	var menu_view := current_level.get_node("CameraViews/MenuView") as Marker2D
	camera.global_position = menu_view.global_position
	camera.force_update_scroll()
	get_tree().paused = true
	play_button.grab_focus()


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
	defense_placement_manager.cancel_drag()
	
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
	spawner.level_won.connect(load_next_level, CONNECT_DEFERRED)
	spawner.level_lost.connect(restart_level, CONNECT_DEFERRED)


func restart_level() -> void:
	# clean and reset everythings
	defense_placement_manager.cancel_drag()
	gameplay_ui.reset_for_new_run()
	game_session.reset_session()
	change_level(levels[current_level_index])
	var gameplay_view := current_level.get_node("CameraViews/GameplayView") as Marker2D
	camera.global_position = gameplay_view.global_position
	camera.force_update_scroll()
	game_session.running = true
	paused_before_system_menu = false
	_close_system_menu()


func load_next_level() -> void:
	var next_level_index := current_level_index + 1

	if next_level_index >= levels.size():
		print("Félicitations ! Tous les niveaux sont terminés.")
		return
	current_level_index = next_level_index
	game_session.reset_session()
	change_level(levels[current_level_index])
	var spawner = current_level.get_node("DangerSpawner")
	game_session.running = true
	spawner.start_game()


func _on_purchase_requested(defense_data: DefenseData) -> void:
	if defense_data == null or overlay_menu != OverlayMenu.NONE:
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
