class_name CombatModifierComponent
extends EffectComponent

const KEY_MODIFIERS: String = "modifiers"


func initialize(config: Dictionary) -> void:
	super.initialize(config)
	component_type = "CombatModifierComponent"


func get_modifiers(instance: EffectInstance) -> Array[CombatModifier]:
	var result: Array[CombatModifier] = []
	var modifiers_data: Variant = configuration.get(KEY_MODIFIERS, [])
	if not modifiers_data is Array:
		return result
	for modifier_data in modifiers_data:
		if not modifier_data is Dictionary:
			continue
		var modifier: CombatModifier = _create_modifier(modifier_data, instance)
		if modifier != null:
			result.append(modifier)
	return result


func _create_modifier(modifier_data: Dictionary, instance: EffectInstance) -> CombatModifier:
	var operation_str: String = modifier_data.get("operation", "MULTIPLY")
	var base_value: float = float(modifier_data.get("value", 1.0))
	var priority: int = int(modifier_data.get("priority", 0))
	var description: String = modifier_data.get("description", "")
	var scaled_value: float = _scale_value(base_value, operation_str, instance.stack_count)
	var mod_id: String = "%s_%s" % [instance.instance_id, modifier_data.get("target", "")]
	var mod_source: String = instance.definition.id
	var mod_metadata: Dictionary = {"effect_id": instance.definition.id, "stack_count": instance.stack_count}
	match operation_str:
		"MULTIPLY":
			return CombatModifier.create_multiply(mod_id, mod_source, scaled_value, priority, description, mod_metadata)
		"ADD":
			return CombatModifier.create_add(mod_id, mod_source, scaled_value, priority, description, mod_metadata)
		"OVERRIDE":
			return CombatModifier.create_override(mod_id, mod_source, scaled_value, priority, description, mod_metadata)
		"MIN":
			return CombatModifier.create_min(mod_id, mod_source, scaled_value, priority, description, mod_metadata)
		"MAX":
			return CombatModifier.create_max(mod_id, mod_source, scaled_value, priority, description, mod_metadata)
	return null


func _scale_value(base_value: float, operation_str: String, stack_count: int) -> float:
	if stack_count <= 1:
		return base_value
	match operation_str:
		"MULTIPLY":
			return 1.0 + (base_value - 1.0) * float(stack_count)
		"ADD":
			return base_value * float(stack_count)
	return base_value
