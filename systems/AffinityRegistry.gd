class_name AffinityRegistry
extends RefCounted

var _affinities: Dictionary = {}


func register(affinity: AffinityDefinition) -> void:
	if affinity.id == "":
		push_error("AffinityRegistry: Cannot register affinity with empty id")
		return
	
	if _affinities.has(affinity.id):
		push_error("AffinityRegistry: Duplicate affinity id '%s'" % affinity.id)
		return
	
	_affinities[affinity.id] = affinity


func get_affinity(affinity_id: String) -> AffinityDefinition:
	if not _affinities.has(affinity_id):
		push_error("AffinityRegistry: Unknown affinity id '%s'" % affinity_id)
		return null
	return _affinities[affinity_id]


func has_affinity(affinity_id: String) -> bool:
	return _affinities.has(affinity_id)


func get_all_affinities() -> Array[AffinityDefinition]:
	var result: Array[AffinityDefinition] = []
	for affinity_id in _affinities:
		result.append(_affinities[affinity_id])
	return result


func get_count() -> int:
	return _affinities.size()
