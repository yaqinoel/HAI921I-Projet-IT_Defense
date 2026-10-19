class_name DefenseData
extends Resource

@export var type: StringName
@export var display_name: String
@export var icon: Texture2D
@export var scene: PackedScene
@export var projectile_scene: PackedScene
@export var cost: int = 100
@export_range(0.05, 10.0, 0.05) var attack_interval: float = 3.0
