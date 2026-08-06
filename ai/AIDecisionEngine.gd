class_name AIDecisionEngine
extends RefCounted

const DECISION_INTERVAL: float = 1.5

var _perception: PerceptionSystem
var _evaluation: EvaluationSystem
var _decision: DecisionSystem
var _command_generator: AICommandGenerator
var _command_dispatcher: CommandDispatcher
var _personality: AIPersonalityDefinition
var _debug_data: AIDebugData
var _team: String = "enemy"
var _decision_timer: float = 0.0
var _ability_registry: AbilityRegistry = null


func initialize(
	perception: PerceptionSystem,
	evaluation: EvaluationSystem,
	decision_sys: DecisionSystem,
	command_generator: AICommandGenerator,
	command_dispatcher: CommandDispatcher,
	personality: AIPersonalityDefinition
) -> void:
	_perception = perception
	_evaluation = evaluation
	_decision = decision_sys
	_command_generator = command_generator
	_command_dispatcher = command_dispatcher
	_personality = personality
	_evaluation.set_personality(personality)
	_debug_data = AIDebugData.new()
	_debug_data.personality_id = personality.id
	_debug_data.personality_name = personality.display_name


func set_ability_registry(registry: AbilityRegistry) -> void:
	_ability_registry = registry


func set_team(team: String) -> void:
	_team = team


func update(delta: float) -> void:
	_decision_timer += delta
	if _decision_timer < DECISION_INTERVAL:
		return
	_decision_timer = 0.0
	_run_decision_cycle()


func get_debug_data() -> AIDebugData:
	return _debug_data


func get_personality() -> AIPersonalityDefinition:
	return _personality


func _run_decision_cycle() -> void:
	EventBus.ai_decision_started.emit(_personality.id)

	var world_state: WorldState = _perception.perceive(_team)
	var evaluations: Array[AIEvaluationResult] = _evaluation.evaluate(world_state)
	var chosen: AIEvaluationResult = _decision.decide(evaluations)

	_debug_data.record_evaluation(evaluations)
	_debug_data.resource_reserve = world_state.get_resource_ratio()

	if chosen != null:
		_debug_data.record_decision(chosen.action_type)
		var command: GameCommand = _command_generator.generate(chosen, _team)
		if command != null:
			_command_dispatcher.dispatch(command)
			var cmd_type: String = _get_command_type_name(command)
			_debug_data.record_command(cmd_type)
			EventBus.ai_command_generated.emit(command, _personality.id)

	EventBus.ai_decision_finished.emit(_personality.id, _debug_data.last_chosen_action)


func _get_command_type_name(command: GameCommand) -> String:
	if command is PlayCardCommand:
		return "PlayCardCommand"
	if command is AbilityCommand:
		return "AbilityCommand"
	return command.get_class()
