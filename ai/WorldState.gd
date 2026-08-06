class_name WorldState
extends RefCounted

var friendly_units: Array[UnitInstance] = []
var enemy_units: Array[UnitInstance] = []
var resource_current: int = 0
var resource_maximum: int = 0
var resource_regen_rate: float = 0.0
var enemy_resource_current: int = 0
var available_cards: Array[UnitDefinition] = []
var affordable_cards: Array[UnitDefinition] = []
var ability_cooldowns: Dictionary = {}
var friendly_nexus_hp_ratio: float = 1.0
var enemy_nexus_hp_ratio: float = 1.0
var match_state: int = 0
var elapsed_match_time: float = 0.0
var battlefield_width: float = 0.0
var friendly_spawn_position: Vector2 = Vector2.ZERO
var enemy_spawn_position: Vector2 = Vector2.ZERO
var affinity_distribution: Dictionary = {}


func get_friendly_unit_count() -> int:
	return friendly_units.size()


func get_enemy_unit_count() -> int:
	return enemy_units.size()


func get_resource_ratio() -> float:
	if resource_maximum <= 0:
		return 0.0
	return float(resource_current) / float(resource_maximum)


func get_closest_enemy_distance(unit: UnitInstance) -> float:
	var closest: float = INF
	for enemy in enemy_units:
		if is_instance_valid(enemy) and enemy.is_alive():
			var dist: float = unit.position.distance_to(enemy.position)
			if dist < closest:
				closest = dist
	return closest


func get_available_ability_ids() -> Array[String]:
	var result: Array[String] = []
	for ability_id: String in ability_cooldowns:
		if ability_cooldowns[ability_id] <= 0.0:
			result.append(ability_id)
	return result
