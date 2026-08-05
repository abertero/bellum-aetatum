class_name EffectComponent
extends RefCounted

var component_type: String = ""
var configuration: Dictionary = {}


func initialize(config: Dictionary) -> void:
	configuration = config.duplicate()


func update(_delta: float, _instance: EffectInstance) -> void:
	pass


func get_modifiers(_instance: EffectInstance) -> Array[CombatModifier]:
	return []


func has_trigger(_trigger_name: String) -> bool:
	return false


func is_expired(_instance: EffectInstance) -> bool:
	return false
