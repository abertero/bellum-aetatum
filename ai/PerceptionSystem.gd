class_name PerceptionSystem
extends RefCounted

var _spatial_query: SpatialQuerySystem
var _economy_system: EconomySystem
var _nexus_system: NexusSystem
var _ability_system: AbilitySystem
var _ability_registry: AbilityRegistry = null
var _stage_definition: StageDefinition


func initialize(
	spatial_query: SpatialQuerySystem,
	economy_system: EconomySystem,
	nexus_system: NexusSystem,
	ability_system: AbilitySystem,
	stage_definition: StageDefinition
) -> void:
	_spatial_query = spatial_query
	_economy_system = economy_system
	_nexus_system = nexus_system
	_ability_system = ability_system
	_stage_definition = stage_definition


func set_ability_registry(registry: AbilityRegistry) -> void:
	_ability_registry = registry


func perceive(team: String) -> WorldState:
	var state := WorldState.new()
	_perceive_units(state, team)
	_perceive_resources(state, team)
	_perceive_cards(state, team)
	_perceive_abilities(state, team)
	_perceive_nexus(state)
	_perceive_battlefield(state)
	_perceive_affinities(state)
	return state


func _perceive_units(state: WorldState, team: String) -> void:
	state.friendly_units = _spatial_query.get_units_by_owner(team)
	var enemy_team: String = "player" if team == "enemy" else "enemy"
	state.enemy_units = _spatial_query.get_units_by_owner(enemy_team)


func _perceive_resources(state: WorldState, team: String) -> void:
	state.resource_current = _economy_system.get_current(team, "imperium")
	state.resource_maximum = _economy_system.get_maximum(team, "imperium")
	state.resource_regen_rate = _economy_system.get_regeneration_rate(team, "imperium")
	var enemy_team: String = "player" if team == "enemy" else "enemy"
	state.enemy_resource_current = _economy_system.get_current(enemy_team, "imperium")


func _perceive_cards(state: WorldState, team: String) -> void:
	var deck: Array[UnitDefinition] = _get_deck_for_team(team)
	state.available_cards = deck
	state.affordable_cards = _filter_affordable(deck, team)


func _perceive_abilities(state: WorldState, team: String) -> void:
	if _ability_system == null:
		return
	var units: Array[UnitInstance] = _spatial_query.get_units_by_owner(team)
	for unit in units:
		if not is_instance_valid(unit) or not unit.is_alive():
			continue
		var all_abilities: Array[AbilityDefinition] = _get_all_ability_definitions()
		for ability_def in all_abilities:
			var remaining: float = _ability_system.get_remaining_cooldown(ability_def.id, unit)
			var key: String = ability_def.id
			if not state.ability_cooldowns.has(key) or remaining <= 0.0:
				state.ability_cooldowns[key] = remaining


func _perceive_nexus(state: WorldState) -> void:
	if _nexus_system == null:
		return
	state.friendly_nexus_hp_ratio = _nexus_system.get_hp_ratio("enemy")
	state.enemy_nexus_hp_ratio = _nexus_system.get_hp_ratio("player")


func _perceive_battlefield(state: WorldState) -> void:
	if _stage_definition == null:
		return
	state.battlefield_width = float(_stage_definition.battlefield_width)
	state.friendly_spawn_position = _stage_definition.enemy_spawn_position
	state.enemy_spawn_position = _stage_definition.player_spawn_position


func _perceive_affinities(state: WorldState) -> void:
	var counts: Dictionary = {}
	for unit in state.friendly_units:
		if not is_instance_valid(unit):
			continue
		var affinity: String = unit.definition.affinity_id
		counts[affinity] = counts.get(affinity, 0) + 1
	state.affinity_distribution = counts


func _get_deck_for_team(team: String) -> Array[UnitDefinition]:
	if team == "enemy":
		return DeckSystem.get_enemy_deck()
	return DeckSystem.get_player_deck()


func _filter_affordable(cards: Array[UnitDefinition], team: String) -> Array[UnitDefinition]:
	var result: Array[UnitDefinition] = []
	var resources: int = _economy_system.get_current(team, "imperium")
	for card in cards:
		if card.cost <= resources:
			result.append(card)
	return result


func _get_all_ability_definitions() -> Array[AbilityDefinition]:
	if _ability_registry == null:
		return []
	return _ability_registry.get_all_abilities()
