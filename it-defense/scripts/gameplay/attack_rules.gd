class_name AttackRules extends RefCounted


const TABLE: Dictionary = {
	&"DefenseExemple": {
		&"DangerExample": 1.0,
		&"DangerCorruption": 1.0,
		&"DangerCrashPC": 1.0,
		&"DangerPhishing": 1.0,
		&"DangerRansomware": 1.0,
		&"DangerVirus": 1.0,
		&"DangerDDOS": 1.0,
		&"DangerHumanError": 1.0,
	},

	&"DefenseAntivirus": {
		&"DangerExample": 1.0,
		&"DangerCorruption": 1.5,
		&"DangerCrashPC": 0.0,
		&"DangerPhishing": 0.5,
		&"DangerRansomware": 2.0,
		&"DangerVirus": 2.5,
		&"DangerDDOS": 0.0,
		&"DangerHumanError": 0.0,
	},

	&"DefenseMailfilter": {
		&"DangerExample": 0.5,
		&"DangerCorruption": 0.5,
		&"DangerCrashPC": 0.0,
		&"DangerPhishing": 2.5,
		&"DangerRansomware": 2.0,
		&"DangerVirus": 0.5,
		&"DangerDDOS": 0.0,
		&"DangerHumanError": 1.0,
	},

	&"DefenseDatashield": {
		&"DangerExample": 1.0,
		&"DangerCorruption": 2.0,
		&"DangerCrashPC": 0.0,
		&"DangerPhishing": 0.0,
		&"DangerRansomware": 2.5,
		&"DangerVirus": 1.0,
		&"DangerDDOS": 0.0,
		&"DangerHumanError": 0.5,
	},

	&"DefenseAntiddos": {
		&"DangerExample": 0.0,
		&"DangerCorruption": 0.0,
		&"DangerCrashPC": 0.0,
		&"DangerPhishing": 0.0,
		&"DangerRansomware": 0.0,
		&"DangerVirus": 0.0,
		&"DangerDDOS": 3.0,
		&"DangerHumanError": 0.0,
	},

	&"DefenseSystemMaintenance": {
		&"DangerExample": 0.5,
		&"DangerCorruption": 0.5,
		&"DangerCrashPC": 2.5,
		&"DangerPhishing": 0.0,
		&"DangerRansomware": 0.0,
		&"DangerVirus": 0.0,
		&"DangerDDOS": 0.0,
		&"DangerHumanError": 2.0,
	},

	&"DefenseSave": {
		&"DangerExample": 0.5,
		&"DangerCorruption": 2.5,
		&"DangerCrashPC": 1.0,
		&"DangerPhishing": 0.0,
		&"DangerRansomware": 2.5,
		&"DangerVirus": 1.0,
		&"DangerDDOS": 0.0,
		&"DangerHumanError": 1.5,
	},

	&"DefenseDNS": {
		&"DangerExample": 0.5,
		&"DangerCorruption": 0.0,
		&"DangerCrashPC": 0.0,
		&"DangerPhishing": 2.0,
		&"DangerRansomware": 0.5,
		&"DangerVirus": 1.0,
		&"DangerDDOS": 0.5,
		&"DangerHumanError": 0.5,
	},

	&"DefenseFirewall": {
		&"DangerExample": 0.5,
		&"DangerCorruption": 0.0,
		&"DangerCrashPC": 0.0,
		&"DangerPhishing": 1.0,
		&"DangerRansomware": 0.5,
		&"DangerVirus": 1.0,
		&"DangerDDOS": 1.5,
		&"DangerHumanError": 0.0,
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
	
static func get_effective_damage(
	defense_type: StringName,
	danger_type: StringName,
	base_damage: float
) -> float:
	return base_damage * get_damage_multiplier(
		defense_type,
		danger_type
	)
