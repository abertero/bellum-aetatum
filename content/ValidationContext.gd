class_name ValidationContext
extends RefCounted

var card_ids: Array[String] = []
var affinity_ids: Array[String] = []
var ability_ids: Array[String] = []
var effect_ids: Array[String] = []
var projectile_ids: Array[String] = []
var game_mode_ids: Array[String] = []
var ai_personality_ids: Array[String] = []

var card_affinity_refs: Dictionary = {}
var card_projectile_refs: Dictionary = {}
var ability_effect_refs: Dictionary = {}
var ability_projectile_refs: Dictionary = {}
var game_mode_personality_refs: Dictionary = {}
var ai_personality_affinity_refs: Dictionary = {}


func has_card_id(id: String) -> bool:
	return id in card_ids


func has_affinity_id(id: String) -> bool:
	return id in affinity_ids


func has_ability_id(id: String) -> bool:
	return id in ability_ids


func has_effect_id(id: String) -> bool:
	return id in effect_ids


func has_projectile_id(id: String) -> bool:
	return id in projectile_ids


func has_game_mode_id(id: String) -> bool:
	return id in game_mode_ids


func has_ai_personality_id(id: String) -> bool:
	return id in ai_personality_ids
