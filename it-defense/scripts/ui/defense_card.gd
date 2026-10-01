extends Control

var defense_data: DefenseData = null

func set_card(data: DefenseData) -> void:
	defense_data = data
	
	if data != null:
		$Icon.visible = true
		$Icon.texture = data.icon
