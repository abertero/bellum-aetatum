class_name DecisionSystem
extends RefCounted


func decide(evaluations: Array[AIEvaluationResult]) -> AIEvaluationResult:
	if evaluations.is_empty():
		return null
	var best: AIEvaluationResult = evaluations[0]
	for i in range(1, evaluations.size()):
		var candidate: AIEvaluationResult = evaluations[i]
		if candidate.score > best.score:
			best = candidate
	if best.score <= 0.0:
		return null
	return best
