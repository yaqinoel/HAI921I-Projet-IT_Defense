class_name TutorialLevel extends Node2D

# signal to main, player is reading hint or not
signal reading_changed(reading: bool)
signal tutorial_finished

@export var training_money: int = 100
@export_range(2.0, 15.0, 0.5) var demo_downtime: float = 5.0

@onready var tutorial_ui: TutorialUI = $TutorialUI
@onready var danger_spawner: Node2D = $DangerSpawner


enum Step {
	WELCOME,
	GOAL,
	WORKSTATIONS,
	INVENTORY,
	CONTROLS,
	WAIT_PURCHASE,
	WAIT_PLACEMENT,
	WAIT_SELECTION,
	WAIT_INFO,
	REMOVE_INFO,
	ATTACK_INTRO,
	WAIT_ATTACK,
	ATTACK_RESULT,
	INTRUSION_INTRO,
	WAIT_INTRUSION,
	INTRUSION_RESULT,
	WAIT_RECOVERY,
	RECOVERY_RESULT,
	WAIT_JOURNAL,
	COMPLETE
}

var active: bool = false
var current_step: Step = Step.WELCOME
var gameplay_ui: GamePlayUI
var game_session: GameSession
var placement_manager: Node2D
var danger_journal: DangerJournal
var tutorial_slot: DefenseSlot
var demo_danger: Danger
var demo_scene: PackedScene
var invaded_station: WorkStation
var purchase_completed: bool = false
var info_opened: bool = false
var journal_opened: bool = false


func _ready() -> void:
	# stop danger spawner, we will generate danger by ourself
	danger_spawner.set_process(false)
	danger_spawner.get_node("Timer").stop()
	danger_spawner.get_node("WaveTimer").stop()
	tutorial_ui.skip_requested.connect(_finish_tutorial)
	tutorial_ui.next_requested.connect(_next_step)
	tutorial_ui.hide()


func setup(ui: GamePlayUI, session: GameSession, manager: Node2D, journal: DangerJournal) -> void:
	gameplay_ui = ui
	game_session = session
	placement_manager = manager
	danger_journal = journal
	gameplay_ui.defense_drag_started.connect(_on_drag_started, CONNECT_DEFERRED)
	placement_manager.defense_placed.connect(_on_defense_placed, CONNECT_DEFERRED)
	placement_manager.selection_changed.connect(_on_selection_changed, CONNECT_DEFERRED)
	placement_manager.defense_removed.connect(_on_defense_removed, CONNECT_DEFERRED)
	for station: WorkStation in game_session.workstations:
		station.work_status_changed.connect(_on_work_status_changed.bind(station), CONNECT_DEFERRED)


func start_tutorial() -> void:
	if active:
		return
	active = true
	game_session.add_money(maxi(0, training_money - game_session.money))
	_show_step(Step.WELCOME)


func _exit_tree() -> void:
	active = false


func set_instruction_visible(value: bool) -> void:
	tutorial_ui.visible = active and value
	if active and value and current_step in [Step.WAIT_INFO, Step.REMOVE_INFO]:
		_restore_selection()


func notify_purchase_completed() -> void:
	if not active or current_step != Step.WAIT_PURCHASE:
		return
	purchase_completed = true


func notify_content_opened(window: StringName) -> void:
	if not active:
		return
	if window == &"defense_info" and current_step == Step.WAIT_INFO:
		info_opened = true
	elif window == &"journal" and current_step == Step.WAIT_JOURNAL:
		journal_opened = true


func notify_content_closed(window: StringName) -> void:
	if not active:
		return
	if window == &"shop" and current_step == Step.WAIT_PURCHASE and purchase_completed:
		_show_step(Step.WAIT_PLACEMENT)
	elif window == &"defense_info" and current_step == Step.WAIT_INFO and info_opened:
		_show_step(Step.REMOVE_INFO)
	elif window == &"journal" and current_step == Step.WAIT_JOURNAL and journal_opened:
		_show_step(Step.COMPLETE)


func _show_step(step: Step) -> void:
	if not active:
		return
	current_step = step
	var title := ""
	var description := ""
	var reading := true
	var show_next := true
	var next_text := "Continuer"
	var focus: CanvasItem
	var focus_size := Vector2(90, 90)
	var progress := 1
	match step:
		Step.WELCOME:
			title = "Bienvenue au bureau"
			description = "Apprenez à protéger le bureau avant le Jour 1. Aucun ennemi n'arrive sans votre accord. Vous pouvez passer la formation à tout moment."
		Step.GOAL:
			progress = 2
			var level_data := danger_spawner.get("level_data") as LevelData
			title = "Votre mission"
			description = "Au Jour 1, terminez les %d vagues avec au moins %d € encore disponibles. Les achats réduisent ce solde : protégez les revenus des ordinateurs !" % [level_data.total_waves, level_data.target_money]
			focus = gameplay_ui.money_label
		Step.WORKSTATIONS:
			progress = 3
			title = "Les ordinateurs rapportent de l'argent"
			description = "Chaque poste en service produit régulièrement de l'argent. La pièce et le montant indiquent un gain. Un poste hors service ne rapporte plus rien jusqu'à sa réparation."
			focus = $WorkStations.get_child(0)
			focus_size = Vector2(130, 130)
		Step.INVENTORY:
			progress = 4
			title = "Votre réserve de défenses"
			description = "Les achats arrivent dans ces 8 cases. Chaque case contient jusqu'à 10 défenses du même type ; le nombre apparaît en bas à droite. La réserve sera vidée avant le Jour 1."
			focus = gameplay_ui.grid
		Step.CONTROLS:
			progress = 5
			title = "Les commandes du bureau"
			description = "Boutique : acheter des défenses. Journal : relire les menaces découvertes. Pause : reprendre, recommencer ou revenir au menu. Paramètres : régler le son. Les fenêtres suspendent la partie."
			focus = gameplay_ui.top_right
			next_text = "Essayer"
		Step.WAIT_PURCHASE:
			progress = 6
			title = "Achetez une défense"
			description = "Ouvrez Boutique, choisissez une défense, consultez ses informations puis cliquez sur Acheter. Fermez ensuite la boutique. Vous disposez de %d € de formation ; si nécessaire, laissez les postes travailler pour gagner davantage." % training_money
			reading = false
			show_next = false
			focus = gameplay_ui.shop_button
		Step.WAIT_PLACEMENT:
			progress = 7
			title = "Placez votre défense"
			description = "Maintenez le clic sur une carte de la réserve, faites-la glisser sur un socle vide puis relâchez. Une pose réussie consomme une unité. Relâcher ailleurs ou annuler avec le clic droit ne consomme rien."
			reading = false
			show_next = false
			focus = _find_filled_card()
		Step.WAIT_SELECTION:
			progress = 8
			title = "Sélectionnez le socle occupé"
			description = "Cliquez sur le socle où vous venez de placer la défense. Sa bordure s'allume et deux actions apparaissent : Info et Retirer."
			reading = false
			show_next = false
			focus = tutorial_slot
		Step.WAIT_INFO:
			info_opened = false
			progress = 9
			title = "Consultez la défense"
			description = "Cliquez sur Info à côté de votre défense. Lisez sa description puis fermez la fenêtre pour revenir à la formation."
			reading = false
			show_next = false
			focus = gameplay_ui.defense_info_button
		Step.REMOVE_INFO:
			progress = 10
			title = "Retirer une défense"
			description = "Retirer libère le socle, sans rendre la carte ni rembourser son prix. Cet essai est facultatif : gardez votre défense et continuez, ou retirez-la puis achetez et placez-en une autre."
			reading = false
			focus = gameplay_ui.remove_defense_button
		Step.ATTACK_INTRO:
			progress = 11
			title = "Une défense attaque automatiquement"
			description = "Votre défense surveille les deux chemins voisins et attaque les menaces compatibles situées à sa droite. Nous allons envoyer une seule cible adaptée pour observer son tir."
			focus = tutorial_slot
			next_text = "Lancer la démonstration"
		Step.WAIT_ATTACK:
			progress = 11
			title = "Observez la défense"
			description = "La cible d'entraînement avance lentement. La défense choisit sa cible et tire automatiquement. Regardez le projectile et la barre de vie de la menace."
			reading = false
			show_next = false
			focus = demo_danger
		Step.ATTACK_RESULT:
			progress = 11
			title = "Menace bloquée !"
			description = "La défense a éliminé sa cible. Chaque type de défense a ses points forts : consultez les descriptions pour choisir une réponse adaptée aux différentes menaces."
			focus = tutorial_slot
		Step.INTRUSION_INTRO:
			progress = 12
			title = "Que se passe-t-il sans protection ?"
			description = "Nous allons placer une seconde menace près d'un ordinateur, derrière la zone protégée. Il s'agit d'une intrusion volontaire pour observer ses conséquences, pas d'un échec de votre défense."
			next_text = "Observer l'intrusion"
		Step.WAIT_INTRUSION:
			progress = 12
			title = "Une menace approche du poste"
			description = "Cette menace contourne la protection pour la démonstration. Observez l'ordinateur lorsqu'elle atteint son espace de travail."
			reading = false
			show_next = false
			focus = demo_danger
		Step.INTRUSION_RESULT:
			progress = 12
			title = "Ordinateur hors service"
			description = "L'ordinateur s'est éteint : ce poste ne produit plus d'argent pendant %.0f secondes. Une autre intrusion ajouterait sa durée au temps restant. Les autres postes continuent de fonctionner." % demo_downtime
			focus = invaded_station
			focus_size = Vector2(130, 130)
			next_text = "Attendre la réparation"
		Step.WAIT_RECOVERY:
			progress = 13
			title = "Le poste se répare"
			description = "L'indication Hors service reste affichée pendant la panne. À la fin du délai, le poste reprendra automatiquement son travail et ses revenus."
			reading = false
			show_next = false
			focus = invaded_station
			focus_size = Vector2(130, 130)
		Step.RECOVERY_RESULT:
			progress = 13
			title = "Poste rétabli"
			description = "L'ordinateur est rallumé et les revenus reprennent. Protéger les postes vous aide à conserver le solde nécessaire pour terminer la journée."
			focus = invaded_station
			focus_size = Vector2(130, 130)
		Step.WAIT_JOURNAL:
			journal_opened = false
			progress = 14
			title = "Retrouvez les menaces dans le journal"
			description = "Ouvrez Journal, consultez une menace rencontrée puis fermez-le. Au Jour 1, des questionnaires présenteront aussi de nouvelles menaces ; la partie s'arrêtera pendant leur lecture."
			reading = false
			show_next = false
			focus = gameplay_ui.journal_button
		Step.COMPLETE:
			progress = 15
			title = "Vous êtes prêt pour le Jour 1"
			description = "Achetez, placez et adaptez vos défenses pour maintenir les postes en service. L'argent, la réserve et les statistiques de formation seront remis à zéro. Vos découvertes restent dans le journal."
			next_text = "Commencer le Jour 1"
	if step in [Step.ATTACK_INTRO, Step.WAIT_JOURNAL, Step.COMPLETE]:
		placement_manager.clear_selection()
	tutorial_ui.show_hint(title, description, reading, show_next)
	tutorial_ui.set_step_details(progress, 15, next_text)
	tutorial_ui.set_focus_target(focus, focus_size)
	reading_changed.emit(reading)
	if step in [Step.WAIT_INFO, Step.REMOVE_INFO]:
		_restore_selection()


func _next_step() -> void:
	if not active or not tutorial_ui.visible:
		return
	match current_step:
		Step.WELCOME: _show_step(Step.GOAL)
		Step.GOAL: _show_step(Step.WORKSTATIONS)
		Step.WORKSTATIONS: _show_step(Step.INVENTORY)
		Step.INVENTORY: _show_step(Step.CONTROLS)
		Step.CONTROLS: _show_step(Step.WAIT_PURCHASE)
		Step.REMOVE_INFO: _show_step(Step.ATTACK_INTRO)
		Step.ATTACK_INTRO: _start_attack_demo()
		Step.ATTACK_RESULT: _show_step(Step.INTRUSION_INTRO)
		Step.INTRUSION_INTRO: _start_intrusion_demo()
		Step.INTRUSION_RESULT: _show_step(Step.WAIT_RECOVERY)
		Step.RECOVERY_RESULT: _show_step(Step.WAIT_JOURNAL)
		Step.COMPLETE: _finish_tutorial()


func _find_filled_card() -> DefenseCard:
	for child in gameplay_ui.grid.get_children():
		var card := child as DefenseCard
		if card != null and not card.is_empty():
			return card
	return null


func _restore_selection() -> void:
	if get_tree().paused or not is_instance_valid(tutorial_slot) or tutorial_slot.is_available():
		return
	if placement_manager.selected_slot != tutorial_slot:
		placement_manager.select_one_slot(tutorial_slot)
	placement_manager.selection_timer.stop()


func _on_defense_placed(slot: DefenseSlot) -> void:
	if not active or current_step != Step.WAIT_PLACEMENT:
		return
	tutorial_slot = slot
	_show_step(Step.WAIT_SELECTION)


func _on_selection_changed(slot: DefenseSlot) -> void:
	if active and current_step == Step.WAIT_SELECTION and slot == tutorial_slot:
		_show_step(Step.WAIT_INFO)
	elif active and current_step in [Step.WAIT_INFO, Step.REMOVE_INFO] and slot != tutorial_slot:
		_restore_selection()


func _on_drag_started(_card: DefenseCard) -> void:
	if not active or not is_instance_valid(placement_manager.preview):
		return
	tutorial_ui.hint_panel.hide()
	placement_manager.preview.tree_exited.connect(_on_drag_ended, CONNECT_DEFERRED)


func _on_drag_ended() -> void:
	if active:
		tutorial_ui.hint_panel.show()


func _on_defense_removed(slot: DefenseSlot) -> void:
	if not active or slot != tutorial_slot or current_step > Step.WAIT_ATTACK:
		return
	_clear_demo()
	tutorial_slot = null
	if _find_filled_card() != null:
		_show_step(Step.WAIT_PLACEMENT)
	else:
		purchase_completed = false
		game_session.add_money(maxi(0, training_money - game_session.money))
		_show_step(Step.WAIT_PURCHASE)


func _choose_demo_scene(data: DefenseData) -> PackedScene:
	for scene: PackedScene in danger_spawner.get("dangers"):
		if scene == null:
			continue
		var instance := scene.instantiate()
		var candidate := instance as Danger
		if candidate == null:
			instance.free()
			continue
		var compatible := candidate.data != null and AttackRules.can_damage(data.type, candidate.data.type)
		candidate.free()
		if compatible:
			return scene
	return null


func _start_attack_demo() -> void:
	if not is_instance_valid(tutorial_slot) or tutorial_slot.is_available():
		_show_step(Step.WAIT_PLACEMENT)
		return
	var defense := tutorial_slot.placed_defense as Defense
	demo_scene = _choose_demo_scene(defense.data)
	if demo_scene == null or defense.data.projectile_scene == null:
		gameplay_ui.show_toast("Cette défense n'a pas de cible compatible pour la formation. Choisissez-en une autre.", "Formation")
		_show_step(Step.REMOVE_INFO)
		return
	var lane := tutorial_slot.detection_areas[0].lane_index
	var spawn_point := danger_spawner.get_node("SpawnPoints").get_child(lane) as Marker2D
	var spawn_position := Vector2(minf(1100.0, maxf(550.0, defense.global_position.x + 170.0)), spawn_point.global_position.y)
	_spawn_demo(lane, spawn_position, false)
	demo_danger.defeated.connect(_on_demo_defeated, CONNECT_DEFERRED)
	demo_danger.tree_exited.connect(_on_attack_demo_exited, CONNECT_DEFERRED)
	_show_step(Step.WAIT_ATTACK)


func _spawn_demo(lane: int, spawn_position: Vector2, intrusion: bool) -> void:
	_clear_demo()
	demo_danger = demo_scene.instantiate() as Danger
	var canonical_data := demo_danger.data
	demo_danger.data = canonical_data.duplicate() as DangerData
	demo_danger.data.speed = 60.0 if intrusion else 18.0
	demo_danger.data.max_health = 40.0
	demo_danger.data.attack_damage = demo_downtime
	demo_danger.lane = lane
	demo_danger.position = $DangerContainer.to_local(spawn_position)
	game_session.register_danger(demo_danger)
	$DangerContainer.add_child(demo_danger)
	danger_journal.discover(canonical_data)


func _on_demo_defeated() -> void:
	if active and current_step == Step.WAIT_ATTACK:
		_show_step(Step.ATTACK_RESULT)


func _on_attack_demo_exited() -> void:
	if active and current_step == Step.WAIT_ATTACK:
		_show_step(Step.ATTACK_INTRO)


func _start_intrusion_demo() -> void:
	var lane := 0
	if is_instance_valid(tutorial_slot):
		for candidate in range(3):
			var covered := false
			for area in tutorial_slot.detection_areas:
				if area.lane_index == candidate:
					covered = true
			if not covered:
				lane = candidate
				break
	invaded_station = $WorkStations.get_child(lane) as WorkStation
	var spawn_point := danger_spawner.get_node("SpawnPoints").get_child(lane) as Marker2D
	var spawn_x := invaded_station.global_position.x + 260.0
	for slot: DefenseSlot in $DefenseSlotContainer.get_children():
		if slot.is_available():
			continue
		for area in slot.detection_areas:
			if area.lane_index == lane:
				spawn_x = minf(spawn_x, slot.global_position.x - 70.0)
	_spawn_demo(lane, Vector2(spawn_x, spawn_point.global_position.y), true)
	_show_step(Step.WAIT_INTRUSION)


func _on_work_status_changed(working: bool, station: WorkStation) -> void:
	if not active or station != invaded_station:
		return
	if not working and current_step == Step.WAIT_INTRUSION:
		_show_step(Step.INTRUSION_RESULT)
	elif working and current_step == Step.WAIT_RECOVERY:
		_show_step(Step.RECOVERY_RESULT)


func _clear_demo() -> void:
	if is_instance_valid(demo_danger):
		demo_danger.queue_free()
	demo_danger = null
	for projectile in $ProjectileContainer.get_children():
		projectile.queue_free()


func _finish_tutorial() -> void:
	if not active:
		return
	active = false
	tutorial_ui.hide()
	tutorial_finished.emit()
