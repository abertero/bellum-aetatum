class_name ResourceInstance
extends RefCounted

var definition: ResourceDefinition
var current_value: int = 0
var generator_level: int = 1
var _accumulated_regeneration: float = 0.0


func _init(p_definition: ResourceDefinition) -> void:
	definition = p_definition
	current_value = definition.starting_value


func can_afford(cost: int) -> bool:
	return current_value >= cost


func spend(cost: int) -> bool:
	if not can_afford(cost):
		return false
	current_value -= cost
	EventBus.resource_spent.emit(definition.id, cost, current_value)
	EventBus.resource_changed.emit(definition.id, current_value, definition.maximum)
	return true


func regenerate(delta: float) -> void:
	if current_value >= definition.maximum:
		return
	var effective_rate: float = definition.regeneration_rate * generator_level
	_accumulated_regeneration += effective_rate * delta
	var whole_amount: int = int(_accumulated_regeneration)
	if whole_amount > 0:
		_accumulated_regeneration -= float(whole_amount)
		var old_value: int = current_value
		current_value = mini(current_value + whole_amount, definition.maximum)
		if current_value != old_value:
			EventBus.resource_generated.emit(definition.id, whole_amount, current_value)
			EventBus.resource_changed.emit(definition.id, current_value, definition.maximum)


func get_current() -> int:
	return current_value


func get_maximum() -> int:
	return definition.maximum


func get_regeneration_rate() -> float:
	return definition.regeneration_rate * generator_level
