class_name AttackRules extends RefCounted


const TABLE: Dictionary = {
	&"DefenseExemple": {
		&"DangerExample" : 1.,
		&"DangerCorruption" : 1.,
		&"DangerCrashPC" : 1.,
		&"DangerPhishing" : 1.,
		&"DangerRansomware" : 1.,
		&"DangerVirus" : 1.,
		
	},
}


static func get_damage_multiplier(
	defense_type: StringName,
	danger_type: StringName
) -> float:
	var row: Dictionary = TABLE.get(defense_type, {})
	return float(row.get(danger_type, 0.0))


static func can_damage(
	defense_type: StringName,
	danger_type: StringName
) -> bool:
	return get_damage_multiplier(defense_type, danger_type) > 0.0
