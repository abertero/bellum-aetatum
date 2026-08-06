class_name AIPersonalityDefinition
extends RefCounted

var id: String = ""
var display_name: String = ""
var description: String = ""
var evaluation_weights: Dictionary = {}
var resource_strategy: String = "balanced"
var spawn_preferences: Array[String] = []
var preferred_affinities: Array[String] = []
var risk_tolerance: float = 0.5
var metadata: Dictionary = {}


static func from_dictionary(data: Dictionary) -> AIPersonalityDefinition:
	var definition := AIPersonalityDefinition.new()
	definition.id = str(data.get("id", ""))
	definition.display_name = str(data.get("display_name", ""))
	definition.description = str(data.get("description", ""))
	definition.resource_strategy = str(data.get("resource_strategy", "balanced"))
	definition.risk_tolerance = float(data.get("risk_tolerance", 0.5))

	var weights_data: Variant = data.get("evaluation_weights", {})
	if weights_data is Dictionary:
		definition.evaluation_weights = weights_data.duplicate()

	var prefs_data: Variant = data.get("spawn_preferences", [])
	if prefs_data is Array:
		for pref in prefs_data:
			definition.spawn_preferences.append(str(pref))

	var affinities_data: Variant = data.get("preferred_affinities", [])
	if affinities_data is Array:
		for affinity in affinities_data:
			definition.preferred_affinities.append(str(affinity))

	var meta_data: Variant = data.get("metadata", {})
	if meta_data is Dictionary:
		definition.metadata = meta_data.duplicate()

	return definition


func get_weight(action_type: String) -> float:
	if evaluation_weights.has(action_type):
		return float(evaluation_weights[action_type])
	return 0.0
