class_name AIRegistry
extends RefCounted

var _personalities: Dictionary = {}


func register(personality: AIPersonalityDefinition) -> void:
	if personality.id == "":
		push_error("AIRegistry: Cannot register personality with empty id")
		return
	if _personalities.has(personality.id):
		push_error("AIRegistry: Duplicate personality id '%s'" % personality.id)
		return
	_personalities[personality.id] = personality


func get_personality(personality_id: String) -> AIPersonalityDefinition:
	if not _personalities.has(personality_id):
		push_error("AIRegistry: Unknown personality id '%s'" % personality_id)
		return null
	return _personalities[personality_id]


func has_personality(personality_id: String) -> bool:
	return _personalities.has(personality_id)


func get_all_personalities() -> Array[AIPersonalityDefinition]:
	var result: Array[AIPersonalityDefinition] = []
	for personality_id in _personalities:
		result.append(_personalities[personality_id])
	return result


func get_count() -> int:
	return _personalities.size()
