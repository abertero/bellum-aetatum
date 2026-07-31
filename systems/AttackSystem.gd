class_name AttackSystem
extends RefCounted

var _registry: AttackModelRegistry


func _init(registry: AttackModelRegistry) -> void:
	_registry = registry


func execute(attacker: UnitInstance, target: UnitInstance) -> DamageResult:
	EventBus.attack_started.emit(attacker, target)
	var result: DamageResult = _resolve_damage(attacker, target)
	EventBus.attack_finished.emit(attacker, target, result)
	return result


func _resolve_damage(attacker: UnitInstance, target: UnitInstance) -> DamageResult:
	var model_key: String = attacker.definition.attack_model
	var model: AttackModel = _registry.resolve(model_key)
	if model == null:
		return DamageResult.new()
	return model.execute(attacker, target)
