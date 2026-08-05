class_name NexusSystem
extends RefCounted

var _nexus_states: Dictionary = {}


func initialize(max_hp: int) -> void:
	var player_nexus: NexusState = NexusState.create("player", max_hp)
	var enemy_nexus: NexusState = NexusState.create("enemy", max_hp)
	_nexus_states["player"] = player_nexus
	_nexus_states["enemy"] = enemy_nexus


func get_nexus(team: String) -> NexusState:
	if not _nexus_states.has(team):
		return null
	return _nexus_states[team]


func damage_nexus(team: String, amount: int) -> void:
	var nexus: NexusState = get_nexus(team)
	if nexus == null:
		return
	nexus.take_damage(amount)
	EventBus.nexus_damaged.emit(team, nexus.current_hp, nexus.max_hp)
	if not nexus.is_alive():
		EventBus.nexus_destroyed.emit(team)


func get_hp_ratio(team: String) -> float:
	var nexus: NexusState = get_nexus(team)
	if nexus == null:
		return 0.0
	return nexus.get_hp_ratio()
