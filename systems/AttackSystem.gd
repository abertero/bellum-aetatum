class_name AttackSystem
extends RefCounted

var _models: Dictionary = {}


func _init() -> void:
	_models["melee"] = MeleeAttackModel.new()


func execute(attacker: UnitInstance, target: UnitInstance) -> DamageResult:
	EventBus.attack_started.emit(attacker, target)
	var result: DamageResult = _resolve_damage(attacker, target)
	EventBus.attack_finished.emit(attacker, target, result)
	return result


func _resolve_damage(attacker: UnitInstance, target: UnitInstance) -> DamageResult:
	var model_key: String = attacker.definition.attack_model
	if not _models.has(model_key):
		return DamageResult.new()
	var model: AttackModel = _models[model_key]
	return model.execute(attacker, target)
