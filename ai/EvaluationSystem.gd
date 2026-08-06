class_name EvaluationSystem
extends RefCounted

var _personality: AIPersonalityDefinition


func set_personality(personality: AIPersonalityDefinition) -> void:
	_personality = personality


func evaluate(world_state: WorldState) -> Array[AIEvaluationResult]:
	var evaluations: Array[AIEvaluationResult] = []
	_evaluate_spawn_options(evaluations, world_state)
	_evaluate_ability_options(evaluations, world_state)
	_evaluate_save_resources(evaluations, world_state)
	return evaluations


func _evaluate_spawn_options(evaluations: Array[AIEvaluationResult], state: WorldState) -> void:
	for card in state.affordable_cards:
		var score: float = _calculate_spawn_score(card, state)
		var data: Dictionary = {"card_definition": card}
		evaluations.append(AIEvaluationResult.create(
			AIEvaluationResult.ACTION_SPAWN_UNIT, score, data
		))


func _evaluate_ability_options(evaluations: Array[AIEvaluationResult], state: WorldState) -> void:
	var available_abilities: Array[String] = state.get_available_ability_ids()
	if available_abilities.is_empty() or state.friendly_units.is_empty():
		return
	var first_unit: UnitInstance = _find_first_valid_unit(state.friendly_units)
	if first_unit == null:
		return
	for ability_id in available_abilities:
		var score: float = _calculate_ability_score(ability_id, state)
		var data: Dictionary = {"ability_id": ability_id, "caster": first_unit}
		evaluations.append(AIEvaluationResult.create(
			AIEvaluationResult.ACTION_USE_ABILITY, score, data
		))


func _evaluate_save_resources(evaluations: Array[AIEvaluationResult], state: WorldState) -> void:
	var score: float = _calculate_save_score(state)
	evaluations.append(AIEvaluationResult.create(
		AIEvaluationResult.ACTION_SAVE_RESOURCES, score
	))


func _calculate_spawn_score(card: UnitDefinition, state: WorldState) -> float:
	var base_score: float = 0.0
	base_score += _score_card_stats(card)
	base_score += _score_strategic_need(state)
	base_score += _score_affinity_preference(card)
	base_score += _score_spawn_preference(card)
	var weight: float = _personality.get_weight(AIEvaluationResult.ACTION_SPAWN_UNIT)
	return base_score * weight


func _calculate_ability_score(ability_id: String, state: WorldState) -> float:
	var base_score: float = 0.5
	base_score += _score_strategic_need(state) * 0.3
	var weight: float = _personality.get_weight(AIEvaluationResult.ACTION_USE_ABILITY)
	return base_score * weight


func _calculate_save_score(state: WorldState) -> float:
	var base_score: float = 0.0
	base_score += _score_resource_preservation(state)
	var weight: float = _personality.get_weight(AIEvaluationResult.ACTION_SAVE_RESOURCES)
	return base_score * weight


func _score_card_stats(card: UnitDefinition) -> float:
	var score: float = 0.0
	score += float(card.attack) * 0.02
	score += float(card.hp) * 0.005
	score += float(card.speed) * 0.1
	var efficiency: float = float(card.attack + card.hp) / float(maxi(card.cost, 1))
	score += efficiency * 0.1
	return clampf(score, 0.0, 1.0)


func _score_strategic_need(state: WorldState) -> float:
	var score: float = 0.0
	if state.friendly_nexus_hp_ratio < 0.5:
		score += 0.3
	if state.enemy_nexus_hp_ratio < 0.3:
		score += 0.2
	var unit_diff: int = state.get_enemy_unit_count() - state.get_friendly_unit_count()
	if unit_diff > 0:
		score += float(unit_diff) * 0.1
	return clampf(score, 0.0, 1.0)


func _score_affinity_preference(card: UnitDefinition) -> float:
	if _personality.preferred_affinities.is_empty():
		return 0.0
	if card.affinity_id in _personality.preferred_affinities:
		return 0.2
	return 0.0


func _score_spawn_preference(card: UnitDefinition) -> float:
	if _personality.spawn_preferences.is_empty():
		return 0.0
	if card.attack_model in _personality.spawn_preferences:
		return 0.15
	return 0.0


func _score_resource_preservation(state: WorldState) -> float:
	var ratio: float = state.get_resource_ratio()
	var strategy: String = _personality.resource_strategy
	match strategy:
		"save":
			return ratio * 0.8
		"spend":
			return ratio * 0.1
		_:
			return ratio * 0.4


func _find_first_valid_unit(units: Array[UnitInstance]) -> UnitInstance:
	for unit in units:
		if is_instance_valid(unit) and unit.is_alive():
			return unit
	return null
