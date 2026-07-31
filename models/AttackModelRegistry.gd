class_name AttackModelRegistry
extends RefCounted

var _models: Dictionary = {}


func register(model_key: String, model: AttackModel) -> void:
	_models[model_key] = model


func resolve(model_key: String) -> AttackModel:
	if not _models.has(model_key):
		return null
	return _models[model_key]
