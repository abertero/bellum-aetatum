class_name AICommandGenerator
extends RefCounted

var _stage_definition: StageDefinition
var _unit_container: Node
var _simulation_context: SimulationContext = null


func initialize(stage_definition: StageDefinition, unit_container: Node) -> void:
	_stage_definition = stage_definition
	_unit_container = unit_container


func set_simulation_context(p_context: SimulationContext) -> void:
	_simulation_context = p_context


func generate(decision: AIEvaluationResult, team: String) -> GameCommand:
	if decision == null:
		return null
	match decision.action_type:
		AIEvaluationResult.ACTION_SPAWN_UNIT:
			return _generate_spawn_command(decision, team)
		AIEvaluationResult.ACTION_USE_ABILITY:
			return _generate_ability_command(decision)
	return null


func _generate_spawn_command(decision: AIEvaluationResult, team: String) -> PlayCardCommand:
	var card: UnitDefinition = decision.get_card_definition()
	if card == null:
		return null
	var spawn_pos: Vector2 = _calculate_spawn_position(team)
	var target_pos: Vector2 = _calculate_target_position(team)
	return PlayCardCommand.create(card, spawn_pos, target_pos, _unit_container, team)


func _generate_ability_command(decision: AIEvaluationResult) -> AbilityCommand:
	var ability_id: String = decision.get_ability_id()
	var caster: UnitInstance = decision.get_caster()
	if ability_id == "" or caster == null:
		return null
	return AbilityCommand.create(ability_id, caster)


func _calculate_spawn_position(team: String) -> Vector2:
	if _stage_definition == null:
		return Vector2.ZERO
	var base_pos: Vector2
	if team == "enemy":
		base_pos = _stage_definition.enemy_spawn_position
	else:
		base_pos = _stage_definition.player_spawn_position
	var offset: Vector2 = _get_random_offset()
	return base_pos + offset


func _get_random_offset() -> Vector2:
	if _simulation_context != null and _simulation_context.get_random() != null:
		var rng: DeterministicRandom = _simulation_context.get_random()
		return Vector2(rng.next_float_range(-20.0, 20.0), rng.next_float_range(-20.0, 20.0))
	return Vector2(randf_range(-20.0, 20.0), randf_range(-20.0, 20.0))


func _calculate_target_position(team: String) -> Vector2:
	if _stage_definition == null:
		return Vector2.ZERO
	if team == "enemy":
		return _stage_definition.player_spawn_position
	return _stage_definition.enemy_spawn_position
