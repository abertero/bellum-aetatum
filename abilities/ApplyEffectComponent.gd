class_name ApplyEffectComponent
extends AbilityComponent


func execute(caster: UnitInstance, _target: Variant, context: Dictionary) -> Array[GameCommand]:
	var effect_id: String = configuration.get("effect_id", "")
	if effect_id == "":
		return []

	var target_mode: String = configuration.get("target", "self")
	var effect_target: Variant = _resolve_target(caster, target_mode)

	if effect_target == null or not is_instance_valid(effect_target):
		return []

	var effect_system: EffectSystem = context.get("effect_system")
	if effect_system == null:
		return []

	effect_system.apply_effect(effect_id, effect_target, caster)
	return []


func _resolve_target(caster: UnitInstance, target_mode: String) -> Variant:
	match target_mode:
		"self":
			return caster
		"target":
			if caster != null and is_instance_valid(caster):
				return caster.get_current_target()
	return null
