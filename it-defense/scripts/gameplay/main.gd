extends Node2D

@export var first_level: PackedScene

@onready var level_container: Node2D = $LevelContainer
@onready var defense_placement_manager = $DefensePlacementManager

var current_level: Node2D


func _ready():
	if first_level != null:
		change_level(first_level)
	
	$GamePlayUI.defense_drag_started.connect(defense_placement_manager.start_drag)


func _process(delta: float) -> void:
	pass


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
