class_name ReplayValidator
extends RefCounted

var _divergence_found: bool = false
var _divergence_tick: int = -1
var _divergence_entity: String = ""
var _expected_value: String = ""
var _actual_value: String = ""
var _divergence_system: String = ""
var _divergence_command: String = ""


func compare_snapshots(expected: MatchSnapshot, actual: MatchSnapshot) -> bool:
	_divergence_found = false
	if expected.simulation_tick != actual.simulation_tick:
		_record_divergence(
			expected.simulation_tick,
			"simulation",
			"tick",
			str(expected.simulation_tick),
			str(actual.simulation_tick),
			"SimulationContext",
			""
		)
		return false
	if expected.match_state != actual.match_state:
		_record_divergence(
			expected.simulation_tick,
			"match",
			"match_state",
			str(expected.match_state),
			str(actual.match_state),
			"MatchFlowSystem",
			""
		)
		return false
	if not _compare_nexus_hp(expected, actual):
		return false
	if not _compare_units(expected, actual):
		return false
	if not _compare_economy(expected, actual):
		return false
	return true


func _compare_nexus_hp(expected: MatchSnapshot, actual: MatchSnapshot) -> bool:
	var exp_nexus: Dictionary = expected.world_state.get("nexus", {})
	var act_nexus: Dictionary = actual.world_state.get("nexus", {})
	for team: String in exp_nexus:
		var exp_hp: int = int(exp_nexus[team].get("current_hp", 0))
		var act_hp: int = int(act_nexus.get(team, {}).get("current_hp", -1))
		if exp_hp != act_hp:
			_record_divergence(
				expected.simulation_tick,
				"nexus_%s" % team,
				"current_hp",
				str(exp_hp),
				str(act_hp),
				"NexusSystem",
				""
			)
			return false
	return true


func _compare_units(expected: MatchSnapshot, actual: MatchSnapshot) -> bool:
	var exp_units: Array = expected.active_units
	var act_units: Array = actual.active_units
	if exp_units.size() != act_units.size():
		_record_divergence(
			expected.simulation_tick,
			"units",
			"count",
			str(exp_units.size()),
			str(act_units.size()),
			"SpawnSystem",
			""
		)
		return false
	return true


func _compare_economy(expected: MatchSnapshot, actual: MatchSnapshot) -> bool:
	var exp_eco: Dictionary = expected.economy_state
	var act_eco: Dictionary = actual.economy_state
	for team: String in exp_eco:
		var exp_val: int = int(exp_eco[team].get("current", 0))
		var act_val: int = int(act_eco.get(team, {}).get("current", -1))
		if exp_val != act_val:
			_record_divergence(
				expected.simulation_tick,
				"economy_%s" % team,
				"current",
				str(exp_val),
				str(act_val),
				"EconomySystem",
				""
			)
			return false
	return true


func _record_divergence(
	tick: int,
	entity: String,
	field: String,
	expected: String,
	actual: String,
	system: String,
	command: String
) -> void:
	_divergence_found = true
	_divergence_tick = tick
	_divergence_entity = "%s.%s" % [entity, field]
	_expected_value = expected
	_actual_value = actual
	_divergence_system = system
	_divergence_command = command


func has_divergence() -> bool:
	return _divergence_found


func get_divergence_report() -> Dictionary:
	return {
		"tick": _divergence_tick,
		"entity": _divergence_entity,
		"expected": _expected_value,
		"actual": _actual_value,
		"system": _divergence_system,
		"command": _divergence_command,
	}


func get_divergence_description() -> String:
	if not _divergence_found:
		return "No divergence detected"
	return "Divergence at tick %d: %s expected=%s actual=%s (system: %s)" % [
		_divergence_tick,
		_divergence_entity,
		_expected_value,
		_actual_value,
		_divergence_system,
	]
