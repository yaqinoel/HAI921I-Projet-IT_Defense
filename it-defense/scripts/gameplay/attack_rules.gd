class_name AttackRules extends RefCounted


const TABLE: Dictionary = {
	&"DefenseExemple": {
		&"DangerExemple": true,
	},
}


static func can_damage(defense_type: StringName, danger_type: StringName) -> bool:
	var row: Dictionary = TABLE.get(defense_type, {})
	return bool(row.get(danger_type, false))
