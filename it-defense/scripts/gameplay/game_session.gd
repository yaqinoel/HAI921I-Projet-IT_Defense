class_name GameSession extends Node2D

signal money_changed(value: int)	

var money: int = 0
var survival_time: float = 0.0
var defended_threats: int = 0
var invaded_threats: int = 0
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


func register_danger(danger: Danger) -> void:
	if not danger.defeated.is_connected(_on_danger_defeated):
		danger.defeated.connect(_on_danger_defeated)
	if not danger.invaded.is_connected(_on_danger_invaded):
		danger.invaded.connect(_on_danger_invaded)


func _on_danger_defeated() -> void:
	if running:
		defended_threats += 1


func _on_danger_invaded() -> void:
	if running:
		invaded_threats += 1


func try_spend_money(amount: int) -> bool:
	if (money - amount) < 0:
		return false
	else:
		money -= amount
		money_changed.emit(money)
		return true


func reset_session() -> void:
	money = 0
	survival_time = 0
	defended_threats = 0
	invaded_threats = 0
	running = false
	money_changed.emit(money)
