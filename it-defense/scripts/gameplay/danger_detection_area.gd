class_name DangerDetectionArea
extends Area2D

@export var lane_index: int = 0

var dangers: Array[Danger] = []

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_area_entered(area: Area2D) -> void:
	var danger := area.get_parent() as Danger
	
	if danger == null:
		return
	
	if danger.lane != lane_index:
		return
	
	if not dangers.has(danger):
		dangers.append(danger)


func _on_area_exited(area: Area2D) -> void:
	var danger := area.get_parent() as Danger
	
	if danger != null:
		dangers.erase(danger)


func get_targets() -> Array[Danger]:
	var targets: Array[Danger] = []

	for i in range(dangers.size() - 1, -1, -1):
		var danger := dangers[i]

		if not is_instance_valid(danger):
			dangers.remove_at(i)
			continue

		if danger.is_dying or danger.is_invading:
			continue

		targets.append(danger)

	return targets
