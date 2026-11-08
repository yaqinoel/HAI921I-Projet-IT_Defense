extends Node2D

@onready var level_container: Node2D = $LevelContainer
@onready var defense_placement_manager = $DefensePlacementManager

@onready var game_session: GameSession = $GameSession
@onready var gameplay_ui: GamePlayUI = $GamePlayUI

@onready var camera: Camera2D = $Camera2D
@onready var system_menu: SystemMenu = $SystemMenu

# main menu references
@onready var menu_layer: CanvasLayer = $StartMenu
@onready var menu_panel: Control = $StartMenu/MainMenu/LeftPanel
@onready var play_button: Button = $StartMenu/MainMenu/LeftPanel/Padding/HomePage/MenuButtons/PlayButton
@onready var menu_settings_button: Button = $StartMenu/MainMenu/LeftPanel/Padding/HomePage/MenuButtons/SettingsButton

@onready var day_transition: DayTransition = $DayTransition

@onready var danger_journal: DangerJournal = $DangerJournal

var current_level: Node2D

@export var levels: Array[PackedScene] = []	# all levels that we can play
@export var tutorial_scene: PackedScene	# only tutorial level
var current_level_index: int = 0

@export var camera_transition_duration: float = 0.9
var camera_transitioning: bool = false

# content winsows status (ex. shop, questionnaire...)
enum ContentWindow {
	NONE,
	SHOP,
	DANGER_INFO,
	MESSAGE_POP,
	QUIZZ
}

# ui menu status (ex. pause, restart, settings, quit)
enum OverlayMenu {
	NONE,
	PAUSE,
	SETTINGS,
	RESTART,
	QUIT,
	RESULT
}

var content_window: ContentWindow = ContentWindow.NONE
var overlay_menu: OverlayMenu = OverlayMenu.NONE
var previous_ui_focus: Control
var previous_menu_process_mode: ProcessMode
var previous_content_focus: Control
var current_quiz: QuizPopup
var result_won: bool = false
var day_transitioning: bool = false

var tutorial_reading: bool = false
var tutorial_completed: bool = false


func _ready():
	if levels.is_empty():
		push_error("Aucun niveau n'a été ajouté dans la liste levels.")
		return
	current_level_index = 0
	var initial_scene := tutorial_scene if tutorial_scene != null else levels[current_level_index]
	change_level(initial_scene)
	game_session.money_changed.connect(gameplay_ui.update_money)

	gameplay_ui.update_money(game_session.money)

	gameplay_ui.defense_drag_started.connect(defense_placement_manager.start_drag)
	gameplay_ui.purchase_requested.connect(_on_purchase_requested)
	gameplay_ui.pause_requested.connect(_on_pause_requested)
	gameplay_ui.settings_requested.connect(_on_settings_requested)
	gameplay_ui.shop_requested.connect(_on_shop_requested)
	gameplay_ui.message_requested.connect(_on_message_requested)
	gameplay_ui.shop_panel.closed.connect(_on_content_window_closed.bind(ContentWindow.SHOP))
	gameplay_ui.message_popup.closed.connect(_on_content_window_closed.bind(ContentWindow.MESSAGE_POP))
	gameplay_ui.defense_remove_requested.connect(defense_placement_manager.remove_selected_defense)
	gameplay_ui.journal_requested.connect(_on_journal_requested)
	gameplay_ui.danger_journal_panel.closed.connect(_on_content_window_closed.bind(ContentWindow.DANGER_INFO))
	
	system_menu.resume_requested.connect(_close_system_menu)
	system_menu.settings_back_requested.connect(_on_settings_back)
	system_menu.restart_requested.connect(restart_level, CONNECT_DEFERRED)
	system_menu.return_to_menu_requested.connect(_on_return_to_menu_requested, CONNECT_DEFERRED)
	system_menu.next_level_requested.connect(_on_next_level_requested, CONNECT_DEFERRED)
	
	defense_placement_manager.selection_changed.connect(gameplay_ui.show_defense_slot_actions)
	
	# move camera to menu view when game start
	var menu_view := current_level.get_node("CameraViews/MenuView") as Marker2D
	camera.global_position = menu_view.global_position
	
	play_button.pressed.connect(_on_play_pressed)
	menu_settings_button.pressed.connect(_on_settings_requested)
	gameplay_ui.hide()	# gameplay ui is hiden by default
	_update_pause_state()
	
	# play menu music when start game
	AudioManager.play_menu_music()


func _update_pause_state() -> void:
	var system_blocked := overlay_menu != OverlayMenu.NONE
	var ui_blocked := system_blocked or day_transitioning or tutorial_reading
	gameplay_ui.set_content_window_open(content_window != ContentWindow.NONE)
	gameplay_ui.set_gameplay_ui_blocked(ui_blocked)
	if is_instance_valid(current_quiz):
		current_quiz.process_mode = Node.PROCESS_MODE_DISABLED if ui_blocked else Node.PROCESS_MODE_ALWAYS
	get_tree().paused = (
		not game_session.running
		or camera_transitioning
		or day_transitioning
		or tutorial_reading
		or content_window != ContentWindow.NONE
		or system_blocked
	)
	var tutorial := current_level as TutorialLevel
	if tutorial != null:
		tutorial.set_instruction_visible(
			game_session.running
			and not camera_transitioning
			and not day_transitioning
			and not system_blocked
			and content_window == ContentWindow.NONE
		)


func _enter_content_window(target: ContentWindow) -> bool:
	if day_transitioning or tutorial_reading:
		return false
	if target == ContentWindow.NONE or not game_session.running or camera_transitioning:
		return false
	if overlay_menu != OverlayMenu.NONE or content_window != ContentWindow.NONE:
		return false
	previous_content_focus = get_viewport().gui_get_focus_owner()
	defense_placement_manager.cancel_drag()
	content_window = target
	_update_pause_state()
	return true


func _on_content_window_closed(target: ContentWindow) -> void:
	if content_window != target:
		return
	var focus := previous_content_focus
	previous_content_focus = null
	content_window = ContentWindow.NONE
	_update_pause_state()
	if (
		content_window == ContentWindow.NONE
		and overlay_menu == OverlayMenu.NONE
		and is_instance_valid(focus)
		and focus.is_visible_in_tree()
		and focus.can_process()
	):
		focus.grab_focus()
	var tutorial := current_level as TutorialLevel
	if tutorial != null:
		var names := {
			ContentWindow.SHOP: &"shop",
			ContentWindow.MESSAGE_POP: &"defense_info",
			ContentWindow.DANGER_INFO: &"journal"
		}
		tutorial.notify_content_closed(names.get(target, &""))


func _on_shop_requested() -> void:
	if _enter_content_window(ContentWindow.SHOP):
		gameplay_ui.shop_panel.show()
		gameplay_ui.shop_panel.buy_button.grab_focus()


func _on_message_requested(message: String, title: String) -> void:
	if _enter_content_window(ContentWindow.MESSAGE_POP):
		gameplay_ui.message_popup.show_message(message, title)
		var tutorial := current_level as TutorialLevel
		if tutorial != null:
			tutorial.notify_content_opened(&"defense_info")


func _on_quiz_open_requested(danger_type: String, quiz: QuizPopup) -> void:
	if quiz != current_quiz or current_level is TutorialLevel:
		return
	if _enter_content_window(ContentWindow.QUIZZ):
		quiz.open_question(danger_type)


func _on_quiz_finished(quiz: QuizPopup) -> void:
	if quiz == current_quiz:
		_on_content_window_closed(ContentWindow.QUIZZ)


func _clear_content_windows() -> void:
	tutorial_reading = false
	previous_content_focus = null
	content_window = ContentWindow.NONE
	
	gameplay_ui.shop_panel.close()
	gameplay_ui.message_popup.close()
	gameplay_ui.danger_journal_panel.close()
	
	if is_instance_valid(current_quiz):
		current_quiz.dismiss()
	defense_placement_manager.cancel_drag()
	


# when play button is pressed
func _on_play_pressed() -> void:
	if day_transitioning:
		return
	if camera_transitioning or overlay_menu != OverlayMenu.NONE or game_session.running:
		return
	if not tutorial_completed and tutorial_scene != null:
		if not current_level is TutorialLevel:
			change_level(tutorial_scene)
	elif current_level is TutorialLevel:
		change_level(levels[current_level_index])
	var original_menu_position := menu_panel.position
	
	# move camera to game view
	var gameplay_view := current_level.get_node("CameraViews/GameplayView") as Marker2D
	await _move_camera_to(gameplay_view.global_position, true, -menu_panel.size.x)

	menu_layer.hide()	# hide start menu
	menu_panel.position = original_menu_position
	gameplay_ui.show()	# show HUD
	_start_current_level()
	
	# play level music correspondent
	_play_current_level_music()

# when pause or settings request 
func _enter_system_menu(target: OverlayMenu) -> void:
	# first time into system menu from game
	if overlay_menu == OverlayMenu.NONE:
		previous_ui_focus = get_viewport().gui_get_focus_owner()	# focus before
		previous_menu_process_mode = menu_layer.process_mode
		menu_layer.process_mode = Node.PROCESS_MODE_DISABLED
		defense_placement_manager.cancel_drag()
	
	# change system menu to target menu
	overlay_menu = target
	_update_pause_state()


func _on_pause_requested() -> void:
	if day_transitioning:
		return
	if camera_transitioning or overlay_menu != OverlayMenu.NONE or not gameplay_ui.visible:
		return
	_enter_system_menu(OverlayMenu.PAUSE)
	system_menu.show_pause()


func _on_settings_requested() -> void:
	if day_transitioning:
		return
	if camera_transitioning or overlay_menu in [OverlayMenu.SETTINGS, OverlayMenu.RESULT]:
		return
	if not gameplay_ui.visible and not menu_layer.visible:
		return
	_enter_system_menu(OverlayMenu.SETTINGS)
	system_menu.show_settings()


func _on_settings_back() -> void:
	if day_transitioning:
		return
	if overlay_menu != OverlayMenu.SETTINGS:
		return
	_close_system_menu()


func _close_system_menu() -> void:
	if overlay_menu == OverlayMenu.NONE:
		return
	system_menu.close()
	overlay_menu = OverlayMenu.NONE
	menu_layer.process_mode = previous_menu_process_mode
	_update_pause_state()
	
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
	if day_transitioning or camera_transitioning:
		return

	# clean or close everythings
	game_session.reset_session()
	_clear_content_windows()
	gameplay_ui.reset_for_new_run()
	
	# change to first level (or we can just keep the same level
	current_level_index = 0
	change_level(levels[current_level_index])
	
	_close_system_menu()
	gameplay_ui.hide()
	_update_pause_state()
	
	# move camera to menu view
	var menu_view := current_level.get_node("CameraViews/MenuView") as Marker2D
	var original_menu_position := menu_panel.position
	menu_panel.position.x = -menu_panel.size.x
	menu_layer.show()
	await _move_camera_to(menu_view.global_position, true, original_menu_position.x)
	play_button.grab_focus()
	
	AudioManager.play_menu_music()


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
	_clear_content_windows()
	
	# clean old level
	if is_instance_valid(current_level):
		level_container.remove_child(current_level)
		current_level.queue_free()
	
	current_level = next_level
	result_won = false
	level_container.add_child(current_level)
	var tutorial := current_level as TutorialLevel
	if tutorial != null:
		tutorial.reading_changed.connect(_on_tutorial_reading_changed)
		tutorial.tutorial_finished.connect(_on_tutorial_finished, CONNECT_DEFERRED)
	
	# pass defense deplacement slot container and defenses container to  defense_placement_manager
	defense_placement_manager.setup_container(slots, defenses)
	
	var stations := current_level.get_node("WorkStations") as Node2D
	game_session.setup_workstations(stations)
	var spawner = current_level.get_node("DangerSpawner")
	spawner.level_won.connect(_on_level_won, CONNECT_DEFERRED)
	spawner.level_lost.connect(_on_level_lost, CONNECT_DEFERRED)
	current_quiz = spawner.get_node("QuizPopup") as QuizPopup
	current_quiz.pause_game = false
	current_quiz.open_requested.connect(_on_quiz_open_requested.bind(current_quiz))
	current_quiz.quiz_finished.connect(_on_quiz_finished.bind(current_quiz))
	_update_pause_state()
	
	# connect spawner signal to danger journal
	spawner.danger_spawned.connect(danger_journal.discover)
	if tutorial != null:
		tutorial.setup(gameplay_ui, game_session, defense_placement_manager, danger_journal)
	
	# play level music correspondent
	_play_current_level_music()


func _on_level_won() -> void:
	_show_level_result(true)


func _on_level_lost() -> void:
	_show_level_result(false)


func _show_level_result(won: bool) -> void:
	if not game_session.running or current_level is TutorialLevel:
		return
	result_won = won
	var spawner := current_level.get_node("DangerSpawner")
	var target_money: int = spawner.level_data.target_money
	var minutes := floori(game_session.survival_time / 60.0)
	var seconds := floori(game_session.survival_time) % 60
	var summary := "Niveau %d · Temps : %02d:%02d\nSolde : %d € / %d €\nBloquées : %d  |  Intrusions : %d" % [
		current_level_index + 1,
		minutes,
		seconds,
		game_session.money,
		target_money,
		game_session.defended_threats,
		game_session.invaded_threats
	]
	if not won:
		summary = "Objectif d'argent non atteint.\n" + summary
	game_session.running = false
	_clear_content_windows()
	_enter_system_menu(OverlayMenu.RESULT)
	var has_next_level := current_level_index + 1 < levels.size()
	system_menu.show_result(won, summary, has_next_level)


func _on_next_level_requested() -> void:
	if day_transitioning:
		return
	if overlay_menu != OverlayMenu.RESULT or not result_won:
		return
	if current_level_index + 1 >= levels.size():
		return
	await load_next_level()


func restart_level() -> void:
	await _transition_to_level(current_level_index, true, current_level is TutorialLevel)


func load_next_level() -> void:
	var next_level_index := current_level_index + 1

	if next_level_index >= levels.size():
		print("Félicitations ! Tous les niveaux sont terminés.")
		return
	await _transition_to_level(next_level_index, true)	# clear inventory before change level


func _transition_to_level(target_index: int, reset_inventory: bool, restart_tutorial: bool = false) -> void:
	if day_transitioning or camera_transitioning:
		return
	if target_index < 0 or target_index >= levels.size():
		return
	var target_scene: PackedScene = tutorial_scene if restart_tutorial else levels[target_index]
	if target_scene == null:
		return

	day_transitioning = true
	game_session.running = false
	_update_pause_state()
	_clear_content_windows()

	if restart_tutorial:
		await day_transition.cover(1, "Formation")
	else:
		await day_transition.cover(target_index + 1)

	_close_system_menu()
	game_session.reset_session()
	if reset_inventory:
		gameplay_ui.reset_for_new_run()

	current_level_index = target_index
	change_level(target_scene)
	var gameplay_view := current_level.get_node("CameraViews/GameplayView") as Marker2D
	camera.global_position = gameplay_view.global_position
	camera.force_update_scroll()
	menu_layer.hide()
	gameplay_ui.show()

	await day_transition.reveal()

	day_transitioning = false
	_start_current_level()


func _on_purchase_requested(defense_data: DefenseData) -> void:
	if (
		defense_data == null
		or not game_session.running
		or camera_transitioning
		or overlay_menu != OverlayMenu.NONE
		or content_window != ContentWindow.SHOP
		or not gameplay_ui.shop_panel.visible
	):
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
	var tutorial := current_level as TutorialLevel
	if tutorial != null:
		tutorial.notify_purchase_completed()

	print("purchase successed", defense_data.display_name)


# move camera position (not linearly)
func _move_camera_to(
	target_position: Vector2,
	slide_menu: bool = false,
	menu_target_x: float = 0.0
) -> void:
	camera_transitioning = true
	_update_pause_state()

	# transition
	var tween := create_tween()
	# set tween can works when game paused
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_method(
		_update_camera_position,
		camera.global_position,
		target_position,
		camera_transition_duration
	)
	
	if slide_menu:
		tween.parallel().tween_property(
			menu_panel,
			"position:x",
			menu_target_x,
			camera_transition_duration
		)

	# block until finished
	await tween.finished
	camera_transitioning = false
	_update_pause_state()

func _update_camera_position(value: Vector2) -> void:
	camera.global_position = value
	camera.force_update_scroll()


func _on_journal_requested() -> void:
	if _enter_content_window(ContentWindow.DANGER_INFO):
		gameplay_ui.danger_journal_panel.open(danger_journal.get_entries())
		var tutorial := current_level as TutorialLevel
		if tutorial != null:
			tutorial.notify_content_opened(&"journal")


func _play_current_level_music() -> void:
	if current_level is TutorialLevel:
		AudioManager.play_tutorial_music()
	else:
		AudioManager.play_level_music(current_level_index)


func _start_current_level() -> void:
	game_session.running = true
	_update_pause_state()
	var tutorial := current_level as TutorialLevel
	if tutorial != null:
		tutorial.start_tutorial()
	else:
		current_level.get_node("DangerSpawner").start_game()


func _on_tutorial_reading_changed(reading: bool) -> void:
	tutorial_reading = reading
	_update_pause_state()


func _on_tutorial_finished() -> void:
	if not current_level is TutorialLevel or day_transitioning or camera_transitioning:
		return
	tutorial_completed = true
	await _transition_to_level(0, true)
