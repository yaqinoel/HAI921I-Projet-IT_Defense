extends Node2D

@export var level_data: LevelData
@export var dangers: Array[PackedScene] = []

@export var preparation_time: float = 4.0

@export var new_danger_weight: float = 2.0

@onready var timer: Timer = $Timer
@onready var wave_timer: Timer = $WaveTimer
@onready var spawn_points: Node2D = $SpawnPoints
@onready var danger_container: Node2D = $"../DangerContainer"
@onready var game_session: GameSession = $"../../../GameSession"
@onready var quiz_popup: QuizPopup = $"QuizPopup"

var current_wave: int = 1
var spawned_this_wave: int = 0
var wave_in_progress: bool = false
var waiting_for_next_wave: bool = false

signal level_won
signal level_lost
signal danger_spawned(data: DangerData)


func _ready() -> void:
	timer.timeout.connect(_on_spawn_timer_timeout)
	wave_timer.timeout.connect(start_next_wave)
	
func _process(_delta: float) -> void:
	if spawned_this_wave < get_spawns_for_current_wave():
		return

	if danger_container.get_child_count() > 0:
		return

	if wave_timer.is_stopped():
		print("Fin de la vague ", current_wave)
		wave_in_progress = false
		wave_timer.start(2.0)

func start_game() -> void:
	await get_tree().create_timer(preparation_time, false).timeout
	start_wave()

func get_danger_name(scene: PackedScene) -> String:
	var state := scene.get_state()
	for i in state.get_node_property_count(0):
		if state.get_node_property_name(0, i) == &"data":
			var data := state.get_node_property_value(0, i) as DangerData
			if data:
				return String(data.type)   # ou data.type
	return ""

func start_wave() -> void:
	if current_wave > level_data.total_waves:
		check_victory()
		return

	print("Début de la vague ", current_wave)

	quiz_popup.ask_about_danger(get_danger_name(dangers[get_unlocked_danger_count() - 1]))
	spawned_this_wave = 0
	update_spawn_interval()
	timer.start()
	
func _on_spawn_timer_timeout() -> void:
	if spawned_this_wave >= get_spawns_for_current_wave():
		timer.stop()
		return

	if spawn_danger():
		spawned_this_wave += 1

	if spawned_this_wave >= get_spawns_for_current_wave():
		timer.stop()
		
func start_next_wave() -> void:
	current_wave += 1
	start_wave()
	
func finish_level() -> void:
	timer.stop()
	wave_timer.stop()
	level_won.emit()
	print("VICTOIRE !!!")
	
func update_spawn_interval() -> void:
	timer.wait_time = maxf(
		0.5,
		level_data.spawn_interval - (current_wave - 1) * 0.1
	)


func get_unlocked_danger_count() -> int:
	var interval := maxi(1, level_data.waves_per_new_danger)
	
	var unlocked := level_data.starting_danger_count \
		+ int((current_wave - 1) / interval)
	return mini(unlocked, dangers.size())


func get_random_danger() -> PackedScene:
	var unlocked_count := get_unlocked_danger_count()

	if unlocked_count <= 0:
		return null

	var total_weight := 0.0
	var weights: Array[float] = []

	for i in range(unlocked_count):
		var weight := new_danger_weight if i == unlocked_count - 1 else 1.0
		weight = 1
		weights.append(weight)
		total_weight += weight

	var random_value := randf() * total_weight

	for i in range(unlocked_count):
		random_value -= weights[i]

		if random_value <= 0.0:
			return dangers[i]

	return dangers[unlocked_count - 1]

func get_spawns_for_current_wave() -> int:
	return level_data.starting_spawns_per_wave \
		+ (current_wave - 1) * level_data.extra_spawns_per_wave

func spawn_danger() -> bool:
	if dangers.is_empty() or spawn_points.get_child_count() == 0:
		return false

	var selected_scene := get_random_danger()

	if selected_scene == null:
		return false

	var lane_index := randi_range(
		0,
		spawn_points.get_child_count() - 1
	)

	var birth_point := spawn_points.get_child(lane_index) as Marker2D
	var new_danger := selected_scene.instantiate() as Danger

	new_danger.lane = lane_index
	game_session.register_danger(new_danger)
	danger_container.add_child(new_danger)
	new_danger.global_position = birth_point.global_position
	
	# send to danger journal
	danger_spawned.emit(new_danger.data)
	return true
	
	
func check_victory() -> void:
	if current_wave > level_data.total_waves:
		if game_session.money >= level_data.target_money:
			finish_level()
		else:
			print("Défaite : objectif d'argent non atteint !.")
			timer.stop()
			wave_timer.stop()
			level_lost.emit()
