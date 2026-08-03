class_name CombatModifierCollection
extends RefCounted

var _modifiers: Array[CombatModifier] = []


func add_modifier(modifier: CombatModifier) -> void:
	_modifiers.append(modifier)


func add_modifiers(modifiers: Array[CombatModifier]) -> void:
	for modifier in modifiers:
		_modifiers.append(modifier)


func get_modifiers() -> Array[CombatModifier]:
	return _modifiers.duplicate()


func get_count() -> int:
	return _modifiers.size()


func is_empty() -> bool:
	return _modifiers.is_empty()


func apply_to(base_value: float) -> float:
	var sorted_modifiers: Array[CombatModifier] = _modifiers.duplicate()
	sorted_modifiers.sort_custom(_compare_priority)
	
	var result: float = base_value
	
	for modifier in sorted_modifiers:
		result = _apply_modifier(result, modifier)
	
	return result


func _compare_priority(a: CombatModifier, b: CombatModifier) -> bool:
	return a.priority < b.priority


func _apply_modifier(value: float, modifier: CombatModifier) -> float:
	match modifier.operation:
		CombatModifier.Operation.MULTIPLY:
			return value * modifier.value
		CombatModifier.Operation.ADD:
			return value + modifier.value
		CombatModifier.Operation.OVERRIDE:
			return modifier.value
		CombatModifier.Operation.MIN:
			return minf(value, modifier.value)
		CombatModifier.Operation.MAX:
			return maxf(value, modifier.value)
		_:
			push_error("CombatModifierCollection: Unknown operation '%s'" % modifier.get_operation_name())
			return value


func get_description() -> String:
	if _modifiers.is_empty():
		return "No modifiers"
	
	var result: String = ""
	for modifier in _modifiers:
		result += "%s (%s): %s %.2f\n" % [modifier.source, modifier.get_operation_name(), modifier.get_operation_name(), modifier.value]
	return result
