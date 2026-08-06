class_name AIEvaluationResult
extends RefCounted

const ACTION_SPAWN_UNIT: String = "spawn_unit"
const ACTION_USE_ABILITY: String = "use_ability"
const ACTION_SAVE_RESOURCES: String = "save_resources"

var action_type: String = ""
var score: float = 0.0
var data: Dictionary = {}


static func create(p_action_type: String, p_score: float, p_data: Dictionary = {}) -> AIEvaluationResult:
	var result := AIEvaluationResult.new()
	result.action_type = p_action_type
	result.score = p_score
	result.data = p_data.duplicate()
	return result


func get_card_definition() -> UnitDefinition:
	if data.has("card_definition"):
		return data["card_definition"] as UnitDefinition
	return null


func get_ability_id() -> String:
	return str(data.get("ability_id", ""))


func get_caster() -> UnitInstance:
	if data.has("caster"):
		return data["caster"] as UnitInstance
	return null
