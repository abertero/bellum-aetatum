class_name MatchRulesDefinition
extends RefCounted

var countdown_duration: float = 3.0
var time_limit: float = 0.0
var nexus_hp: int = 100
var victory_conditions: Array[Dictionary] = []


static func from_dictionary(data: Dictionary) -> MatchRulesDefinition:
	var rules := MatchRulesDefinition.new()
	rules.countdown_duration = float(data.get("countdown_duration", 3.0))
	rules.time_limit = float(data.get("time_limit", 0.0))
	rules.nexus_hp = int(data.get("nexus_hp", 100))

	var conditions_data: Variant = data.get("victory_conditions", [])
	if conditions_data is Array:
		for condition in conditions_data:
			if condition is Dictionary:
				rules.victory_conditions.append(condition.duplicate())

	return rules
