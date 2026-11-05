class_name LevelData
extends Resource

@export_group("Waves")
@export var total_waves: int = 4
@export var starting_spawns_per_wave: int = 5
@export var extra_spawns_per_wave: int = 2

@export_group("Dangers")
@export var starting_danger_count: int = 1
@export var waves_per_new_danger: int = 1

@export_group("Spawn")
@export var spawn_interval: float = 2.5

@export_group("Economie")
@export var target_money: int = 1000
