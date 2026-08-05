class_name EffectSystem
extends Node

var _registry: EffectRegistry = null
var _active_effects: Dictionary = {}
var _all_instances: Array[EffectInstance] = []


func initialize(registry: EffectRegistry) -> void:
	_registry = registry
	_connect_signals()


func _connect_signals() -> void:
	EventBus.unit_died.connect(_on_unit_died)
	EventBus.attack_started.connect(_on_attack_started)
	EventBus.action_performed.connect(_on_action_performed)


func _physics_process(delta: float) -> void:
	_update_all_effects(delta)
	_cleanup_expired_effects()


func apply_effect(effect_id: String, owner: UnitInstance, effect_source: Variant = null) -> EffectInstance:
	if _registry == null:
		return null

	var definition: EffectDefinition = _registry.get_effect(effect_id)
	if definition == null:
		return null

	var existing: EffectInstance = _find_existing_effect(owner, effect_id)
	if existing != null:
		return _handle_stacking(existing, definition)

	var instance: EffectInstance = EffectInstance.create(definition, owner, effect_source)
	instance.initialize_runtime()
	_add_effect_to_tracking(instance)
	EventBus.effect_applied.emit(instance)
	return instance


func remove_effect(instance_id: String) -> void:
	var instance: EffectInstance = _find_instance(instance_id)
	if instance == null:
		return
	instance.remove()
	_remove_effect_from_tracking(instance)
	EventBus.effect_removed.emit(instance)


func remove_all_effects_from(unit: UnitInstance) -> void:
	if not _active_effects.has(unit):
		return
	var effects: Array = _active_effects[unit].duplicate()
	for instance in effects:
		if instance is EffectInstance:
			remove_effect(instance.instance_id)
	_active_effects.erase(unit)


func get_effects_for_unit(unit: UnitInstance) -> Array[EffectInstance]:
	var result: Array[EffectInstance] = []
	if not _active_effects.has(unit):
		return result
	var effects: Array = _active_effects[unit]
	for instance in effects:
		if instance is EffectInstance and instance.is_active():
			result.append(instance)
	return result


func get_modifiers(unit: UnitInstance) -> Array[CombatModifier]:
	var result: Array[CombatModifier] = []
	var effects: Array[EffectInstance] = get_effects_for_unit(unit)
	for effect in effects:
		var modifiers: Array[CombatModifier] = effect.get_modifiers()
		for modifier in modifiers:
			result.append(modifier)
	return result


func get_active_effect_count() -> int:
	return _all_instances.size()


func _handle_stacking(existing: EffectInstance, definition: EffectDefinition) -> EffectInstance:
	match definition.stacking_policy:
		"NO_STACK":
			return existing
		"STACK":
			existing.add_stack()
			EventBus.effect_stack_changed.emit(existing)
			return existing
		"REFRESH_DURATION":
			existing.refresh_duration()
			EventBus.effect_refreshed.emit(existing)
			return existing
		"REPLACE":
			remove_effect(existing.instance_id)
			var instance: EffectInstance = EffectInstance.create(definition, existing.owner, existing.source)
			instance.initialize_runtime()
			_add_effect_to_tracking(instance)
			EventBus.effect_applied.emit(instance)
			return instance
	return existing


func _add_effect_to_tracking(instance: EffectInstance) -> void:
	var owner_unit: Variant = instance.owner
	if not _active_effects.has(owner_unit):
		_active_effects[owner_unit] = []
	_active_effects[owner_unit].append(instance)
	_all_instances.append(instance)
	_sync_unit_active_effects(owner_unit)


func _remove_effect_from_tracking(instance: EffectInstance) -> void:
	var owner_unit: Variant = instance.owner
	if _active_effects.has(owner_unit):
		_active_effects[owner_unit].erase(instance)
		if _active_effects[owner_unit].is_empty():
			_active_effects.erase(owner_unit)
	_all_instances.erase(instance)
	_sync_unit_active_effects(owner_unit)


func _sync_unit_active_effects(owner_unit: Variant) -> void:
	if owner_unit == null or not is_instance_valid(owner_unit):
		return
	if not owner_unit is UnitInstance:
		return
	var unit: UnitInstance = owner_unit as UnitInstance
	unit.active_effects = []
	if _active_effects.has(owner_unit):
		var effects: Array = _active_effects[owner_unit]
		for instance in effects:
			if instance is EffectInstance and instance.is_active():
				unit.active_effects.append(instance)


func _find_existing_effect(unit: UnitInstance, effect_id: String) -> EffectInstance:
	if not _active_effects.has(unit):
		return null
	var effects: Array = _active_effects[unit]
	for instance in effects:
		if instance is EffectInstance and instance.is_active() and instance.definition.id == effect_id:
			return instance
	return null


func _find_instance(instance_id: String) -> EffectInstance:
	for instance in _all_instances:
		if instance is EffectInstance and instance.instance_id == instance_id:
			return instance
	return null


func _update_all_effects(delta: float) -> void:
	var instances: Array[EffectInstance] = _all_instances.duplicate()
	for instance in instances:
		if instance is EffectInstance:
			instance.update(delta)


func _cleanup_expired_effects() -> void:
	var expired: Array[EffectInstance] = []
	for instance in _all_instances:
		if instance is EffectInstance and instance.is_expired():
			expired.append(instance)
	for instance in expired:
		_remove_effect_from_tracking(instance)
		EventBus.effect_expired.emit(instance)


func _on_unit_died(unit: UnitInstance) -> void:
	remove_all_effects_from(unit)


func _on_attack_started(_attacker: UnitInstance, _target: UnitInstance) -> void:
	pass


func _on_action_performed(_action: GameAction) -> void:
	pass
