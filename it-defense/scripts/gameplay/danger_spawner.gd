extends Node2D

@export var dangers: Array[PackedScene] = []
@export var interval: float = 2.0

@onready var timer: Timer = $Timer
@onready var spawn_points: Node2D = $SpawnPoints
@onready var danger_container: Node2D = $"../Dangers"

func _ready() -> void:
	timer.wait_time = interval
	timer.timeout.connect(spawn_danger)
	timer.start()
	
func spawn_danger() -> void:
	if dangers.is_empty() or spawn_points.get_child_count() == 0:
		return

	var lane_index := randi_range(0, spawn_points.get_child_count() - 1)
	var birth_point := spawn_points.get_child(lane_index) as Marker2D
	var new_danger := dangers.pick_random().instantiate() as Danger

	new_danger.lane = lane_index
	danger_container.add_child(new_danger)
	new_danger.global_position = birth_point.global_position
