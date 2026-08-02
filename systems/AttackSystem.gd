class_name AttackSystem
extends RefCounted

var _registry: AttackModelRegistry


func _init(registry: AttackModelRegistry) -> void:
	_registry = registry


func execute(attacker: UnitInstance, target: UnitInstance) -> DamageAction:
	EventBus.attack_started.emit(attacker, target)
	var action: DamageAction = _resolve_damage(attacker, target)
	EventBus.attack_finished.emit(action)
	return action


func _resolve_damage(attacker: UnitInstance, target: UnitInstance) -> DamageAction:
	var model_key: String = attacker.definition.attack_model
	var model: AttackModel = _registry.resolve(model_key)
	if model == null:
		return DamageAction.new()
	return model.execute(attacker, target)
