class_name EconomySystem
extends Node

var _simulation_context: SimulationContext
var _resource_definitions: Dictionary = {}
var _player_resources: Dictionary = {}


func initialize(simulation_context: SimulationContext) -> void:
	_simulation_context = simulation_context
	_load_resource_definitions()
	_initialize_player_resources()


func _load_resource_definitions() -> void:
	var data: Variant = JsonLoader.load_json("res://data/resources/resources.json")
	if data == null or not data.has("resources"):
		push_error("EconomySystem: failed to load resource definitions")
		return
	for resource_data: Dictionary in data["resources"]:
		var definition: ResourceDefinition = ResourceDefinition.from_dictionary(resource_data)
		_resource_definitions[definition.id] = definition


func _initialize_player_resources() -> void:
	_player_resources["player"] = _create_resource_set()
	_player_resources["enemy"] = _create_resource_set()


func _create_resource_set() -> Dictionary:
	var resources: Dictionary = {}
	for resource_id: String in _resource_definitions:
		var definition: ResourceDefinition = _resource_definitions[resource_id]
		resources[resource_id] = ResourceInstance.new(definition)
	return resources


func _physics_process(_delta: float) -> void:
	for team: String in _player_resources:
		var resources: Dictionary = _player_resources[team]
		for resource_id: String in resources:
			var instance: ResourceInstance = resources[resource_id]
			instance.regenerate(_simulation_context.delta_time)


func can_afford(team: String, resource_id: String, cost: int) -> bool:
	if not _player_resources.has(team):
		return false
	var resources: Dictionary = _player_resources[team]
	if not resources.has(resource_id):
		return false
	var instance: ResourceInstance = resources[resource_id]
	return instance.can_afford(cost)


func spend(team: String, resource_id: String, cost: int) -> bool:
	if not _player_resources.has(team):
		return false
	var resources: Dictionary = _player_resources[team]
	if not resources.has(resource_id):
		return false
	var instance: ResourceInstance = resources[resource_id]
	return instance.spend(cost)


func get_current(team: String, resource_id: String) -> int:
	if not _player_resources.has(team):
		return 0
	var resources: Dictionary = _player_resources[team]
	if not resources.has(resource_id):
		return 0
	var instance: ResourceInstance = resources[resource_id]
	return instance.get_current()


func get_maximum(team: String, resource_id: String) -> int:
	if not _player_resources.has(team):
		return 0
	var resources: Dictionary = _player_resources[team]
	if not resources.has(resource_id):
		return 0
	var instance: ResourceInstance = resources[resource_id]
	return instance.get_maximum()


func get_regeneration_rate(team: String, resource_id: String) -> float:
	if not _player_resources.has(team):
		return 0.0
	var resources: Dictionary = _player_resources[team]
	if not resources.has(resource_id):
		return 0.0
	var instance: ResourceInstance = resources[resource_id]
	return instance.get_regeneration_rate()


func set_generator_level(team: String, resource_id: String, level: int) -> void:
	if not _player_resources.has(team):
		return
	var resources: Dictionary = _player_resources[team]
	if not resources.has(resource_id):
		return
	var instance: ResourceInstance = resources[resource_id]
	instance.generator_level = maxi(1, level)
