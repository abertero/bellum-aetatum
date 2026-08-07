class_name StateHasher
extends RefCounted

const _HASH_PRIME: int = 31
const _HASH_OFFSET: int = 14695981039346656037


static func hash_world_state(state: Dictionary) -> int:
	var hash: int = _HASH_OFFSET
	hash = _combine_hash(hash, _hash_value(state.get("tick", 0)))
	hash = _combine_hash(hash, _hash_value(state.get("match_state", 0)))
	var nexus: Dictionary = state.get("nexus", {})
	for team: String in nexus:
		hash = _combine_hash(hash, _hash_string(team))
		var nexus_data: Dictionary = nexus[team]
		hash = _combine_hash(hash, _hash_value(nexus_data.get("current_hp", 0)))
		hash = _combine_hash(hash, _hash_value(nexus_data.get("max_hp", 0)))
	var units: Array = state.get("units", [])
	hash = _combine_hash(hash, _hash_value(units.size()))
	for unit_data in units:
		if unit_data is Dictionary:
			hash = _combine_hash(hash, _hash_unit(unit_data))
	var eco: Dictionary = state.get("economy", {})
	for team: String in eco:
		hash = _combine_hash(hash, _hash_string(team))
		var eco_data: Dictionary = eco[team]
		hash = _combine_hash(hash, _hash_value(eco_data.get("current", 0)))
	return hash


static func _hash_unit(unit_data: Dictionary) -> int:
	var hash: int = _HASH_OFFSET
	hash = _combine_hash(hash, _hash_string(str(unit_data.get("entity_id", ""))))
	hash = _combine_hash(hash, _hash_value(int(unit_data.get("current_hp", 0))))
	hash = _combine_hash(hash, _hash_value(int(unit_data.get("state", 0))))
	var pos: Dictionary = unit_data.get("position", {})
	hash = _combine_hash(hash, _hash_value(int(float(pos.get("x", 0)) * 100)))
	hash = _combine_hash(hash, _hash_value(int(float(pos.get("y", 0)) * 100)))
	return hash


static func _combine_hash(current: int, value: int) -> int:
	return ((current * _HASH_PRIME) ^ value) & 0x7FFFFFFFFFFFFFFF


static func _hash_value(value: Variant) -> int:
	if value is int:
		return value
	if value is float:
		return int(value * 1000)
	if value is String:
		return _hash_string(value)
	if value is bool:
		return 1 if value else 0
	return 0


static func _hash_string(s: String) -> int:
	var hash: int = _HASH_OFFSET
	for i in range(s.length()):
		hash = ((hash * _HASH_PRIME) ^ s.unicode_at(i)) & 0x7FFFFFFFFFFFFFFF
	return hash
