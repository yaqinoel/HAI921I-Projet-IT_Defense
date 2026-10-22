class_name GameSession extends Node2D

signal money_changed(value: int)	

var money: int = 0
var survival_time: float = 0.0
var running: bool = false
var workstations: Array[WorkStation] = []


func _process(delta: float) -> void:
	if running:
		survival_time += delta


func setup_workstations(container: Node2D) -> void:
	workstations.clear()

	for child in container.get_children():
		var station := child as WorkStation
		if station != null:
			workstations.append(station)
			station.income_generated.connect(add_money)


func add_money(amount: int) -> void:
	money += amount
	money_changed.emit(money)


func reset_session() -> void:
	money = 0
	survival_time = 0
	running = false
