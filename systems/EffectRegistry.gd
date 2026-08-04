class_name EffectRegistry
extends RefCounted

var _effects: Dictionary = {}


func register(effect: EffectDefinition) -> void:
	if effect.id == "":
		push_error("EffectRegistry: Cannot register effect with empty id")
		return

	if _effects.has(effect.id):
		push_error("EffectRegistry: Duplicate effect id '%s'" % effect.id)
		return

	_effects[effect.id] = effect


func get_effect(effect_id: String) -> EffectDefinition:
	if not _effects.has(effect_id):
		push_error("EffectRegistry: Unknown effect id '%s'" % effect_id)
		return null
	return _effects[effect_id]


func has_effect(effect_id: String) -> bool:
	return _effects.has(effect_id)


func get_all_effects() -> Array[EffectDefinition]:
	var result: Array[EffectDefinition] = []
	for effect_id in _effects:
		result.append(_effects[effect_id])
	return result


func get_count() -> int:
	return _effects.size()
