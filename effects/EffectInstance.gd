class_name EffectInstance
extends RefCounted

enum State { ACTIVE, EXPIRED, REMOVED }

var instance_id: String = ""
var definition: EffectDefinition = null
var source: Variant = null
var owner: Variant = null
var remaining_duration: float = 0.0
var stack_count: int = 1
var state: int = State.ACTIVE
var metadata: Dictionary = {}

static var _next_id: int = 0


static func create(p_definition: EffectDefinition, p_owner: Variant, p_source: Variant, p_duration: float) -> EffectInstance:
	var instance := EffectInstance.new()
	EffectInstance._next_id += 1
	instance.instance_id = "effect_%d" % EffectInstance._next_id
	instance.definition = p_definition
	instance.owner = p_owner
	instance.source = p_source
	instance.remaining_duration = p_duration
	instance.stack_count = 1
	instance.state = State.ACTIVE
	return instance


func update(delta: float) -> void:
	if state != State.ACTIVE:
		return
	if remaining_duration <= 0.0:
		return
	remaining_duration -= delta
	if remaining_duration <= 0.0:
		remaining_duration = 0.0
		state = State.EXPIRED


func is_expired() -> bool:
	return state == State.EXPIRED


func is_active() -> bool:
	return state == State.ACTIVE


func refresh_duration() -> void:
	remaining_duration = definition.duration
	state = State.ACTIVE


func add_stack() -> void:
	stack_count += 1


func remove() -> void:
	state = State.REMOVED


func has_trigger(trigger_name: String) -> bool:
	if definition == null:
		return false
	return trigger_name in definition.triggers


func get_attack_modifiers() -> Array[CombatModifier]:
	return _generate_modifiers("attack")


func get_defense_modifiers() -> Array[CombatModifier]:
	return _generate_modifiers("defense")


func _generate_modifiers(target: String) -> Array[CombatModifier]:
	var result: Array[CombatModifier] = []
	if definition == null or not is_active():
		return result
	for modifier_data in definition.modifiers:
		if str(modifier_data.get("target", "")) != target:
			continue
		var modifier: CombatModifier = _create_modifier(modifier_data)
		if modifier != null:
			result.append(modifier)
	return result


func _create_modifier(modifier_data: Dictionary) -> CombatModifier:
	var operation_str: String = modifier_data.get("operation", "MULTIPLY")
	var base_value: float = float(modifier_data.get("value", 1.0))
	var priority: int = int(modifier_data.get("priority", 0))
	var description: String = modifier_data.get("description", "")
	var scaled_value: float = _scale_value(base_value, operation_str)
	var mod_id: String = "%s_%s" % [instance_id, modifier_data.get("target", "")]
	var mod_source: String = definition.id
	var mod_metadata: Dictionary = {"effect_id": definition.id, "stack_count": stack_count}
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


func _scale_value(base_value: float, operation_str: String) -> float:
	if stack_count <= 1:
		return base_value
	match operation_str:
		"MULTIPLY":
			return 1.0 + (base_value - 1.0) * float(stack_count)
		"ADD":
			return base_value * float(stack_count)
	return base_value
