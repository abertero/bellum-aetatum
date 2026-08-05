class_name AbilityRegistry
extends RefCounted

var _abilities: Dictionary = {}


func register(ability: AbilityDefinition) -> void:
	if ability.id == "":
		push_error("AbilityRegistry: Cannot register ability with empty id")
		return

	if _abilities.has(ability.id):
		push_error("AbilityRegistry: Duplicate ability id '%s'" % ability.id)
		return

	_abilities[ability.id] = ability


func get_ability(ability_id: String) -> AbilityDefinition:
	if not _abilities.has(ability_id):
		push_error("AbilityRegistry: Unknown ability id '%s'" % ability_id)
		return null
	return _abilities[ability_id]


func has_ability(ability_id: String) -> bool:
	return _abilities.has(ability_id)


func get_all_abilities() -> Array[AbilityDefinition]:
	var result: Array[AbilityDefinition] = []
	for ability_id in _abilities:
		result.append(_abilities[ability_id])
	return result


func get_count() -> int:
	return _abilities.size()
