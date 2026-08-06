class_name ContentIndexes
extends RefCounted

var cards_by_affinity: Dictionary = {}
var cards_by_cost: Dictionary = {}
var abilities_by_owner_type: Dictionary = {}
var effects_by_category: Dictionary = {}
var projectiles_by_type: Dictionary = {}
var ai_personalities: Dictionary = {}
var game_modes: Dictionary = {}


func get_cards_for_affinity(affinity_id: String) -> Array[String]:
	if cards_by_affinity.has(affinity_id):
		return cards_by_affinity[affinity_id].duplicate()
	return []


func get_cards_for_cost(cost: int) -> Array[String]:
	if cards_by_cost.has(cost):
		return cards_by_cost[cost].duplicate()
	return []


func get_projectiles_of_type(projectile_type: String) -> Array[String]:
	if projectiles_by_type.has(projectile_type):
		return projectiles_by_type[projectile_type].duplicate()
	return []


func get_statistics() -> Dictionary:
	var stats: Dictionary = {}
	stats["cards_by_affinity"] = cards_by_affinity.size()
	stats["cards_by_cost"] = cards_by_cost.size()
	stats["projectiles_by_type"] = projectiles_by_type.size()
	stats["ai_personalities"] = ai_personalities.size()
	stats["game_modes"] = game_modes.size()
	return stats
