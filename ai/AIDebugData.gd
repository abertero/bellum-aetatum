class_name AIDebugData
extends RefCounted

var personality_id: String = ""
var personality_name: String = ""
var last_evaluation_scores: Dictionary = {}
var last_chosen_action: String = ""
var last_generated_command: String = ""
var resource_reserve: float = 0.0
var decision_count: int = 0


func record_evaluation(evaluations: Array[AIEvaluationResult]) -> void:
	last_evaluation_scores.clear()
	for evaluation in evaluations:
		var key: String = evaluation.action_type
		if evaluation.data.has("card_definition"):
			var card: UnitDefinition = evaluation.data["card_definition"] as UnitDefinition
			if card != null:
				key += ":%s" % card.name
		elif evaluation.data.has("ability_id"):
			key += ":%s" % evaluation.data["ability_id"]
		last_evaluation_scores[key] = evaluation.score


func record_decision(action_type: String) -> void:
	last_chosen_action = action_type
	decision_count += 1


func record_command(command_type: String) -> void:
	last_generated_command = command_type


func get_summary() -> String:
	var text: String = "Personality: %s\n" % personality_name
	text += "Decisions: %d\n" % decision_count
	text += "Last Action: %s\n" % last_chosen_action
	text += "Last Command: %s\n" % last_generated_command
	text += "Reserve: %.1f\n" % resource_reserve
	text += "---\nScores:\n"
	for key: String in last_evaluation_scores:
		text += "  %s: %.2f\n" % [key, last_evaluation_scores[key]]
	return text
