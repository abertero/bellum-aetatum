class_name MatchFlowSystem
extends Node

var _current_state: int = MatchState.State.LOADING
var _elapsed_match_time: float = 0.0
var _winner: String = ""
var _loser: String = ""
var _countdown_remaining: float = 0.0
var _rules: MatchRulesDefinition = null
var _conditions: Array[MatchCondition] = []
var _nexus_system: NexusSystem = null
var _simulation_context: SimulationContext = null
var _last_pipeline_name: String = ""
var _last_executed_node: String = ""


func initialize(rules: MatchRulesDefinition, simulation_context: SimulationContext) -> void:
	_rules = rules
	_simulation_context = simulation_context
	_build_conditions()


func set_nexus_system(nexus_system: NexusSystem) -> void:
	_nexus_system = nexus_system


func _physics_process(delta: float) -> void:
	if _simulation_context == null:
		return
	var sim_delta: float = _simulation_context.delta_time
	match _current_state:
		MatchState.State.COUNTDOWN:
			_update_countdown(sim_delta)
		MatchState.State.RUNNING:
			_update_running(sim_delta)


func start_match() -> void:
	_transition_to(MatchState.State.INITIALIZING)
	_transition_to(MatchState.State.COUNTDOWN)
	_countdown_remaining = _rules.countdown_duration
	EventBus.countdown_started.emit(_countdown_remaining)


func pause_match() -> void:
	if _current_state != MatchState.State.RUNNING:
		return
	_simulation_context.paused = true
	_transition_to(MatchState.State.PAUSED)
	EventBus.match_paused.emit()


func resume_match() -> void:
	if _current_state != MatchState.State.PAUSED:
		return
	_simulation_context.paused = false
	_transition_to(MatchState.State.RUNNING)
	EventBus.match_resumed.emit()


func get_current_state() -> int:
	return _current_state


func get_elapsed_match_time() -> float:
	return _elapsed_match_time


func get_countdown_remaining() -> float:
	return _countdown_remaining


func get_winner() -> String:
	return _winner


func get_loser() -> String:
	return _loser


func record_pipeline_execution(pipeline_name: String, node_name: String) -> void:
	_last_pipeline_name = pipeline_name
	_last_executed_node = node_name


func get_last_pipeline_name() -> String:
	return _last_pipeline_name


func get_last_executed_node() -> String:
	return _last_executed_node


func _update_countdown(delta: float) -> void:
	_countdown_remaining -= delta
	if _countdown_remaining <= 0.0:
		_countdown_remaining = 0.0
		_transition_to(MatchState.State.RUNNING)
		EventBus.match_started.emit()


func _update_running(delta: float) -> void:
	_elapsed_match_time += delta
	_evaluate_conditions()


func _evaluate_conditions() -> void:
	var context: Dictionary = _build_condition_context()
	for condition in _conditions:
		if condition.check(context):
			_resolve_condition(condition)
			return


func _resolve_condition(condition: MatchCondition) -> void:
	var desc: String = condition.get_description()
	if condition is DestroyEnemyNexusCondition:
		_winner = "player"
		_loser = "enemy"
		_transition_to(MatchState.State.VICTORY)
		EventBus.victory.emit(_winner, desc)
	elif condition is DestroyPlayerNexusCondition:
		_winner = "enemy"
		_loser = "player"
		_transition_to(MatchState.State.DEFEAT)
		EventBus.defeat.emit(_loser, desc)
	elif condition is TimeLimitCondition:
		_transition_to(MatchState.State.DRAW)
		EventBus.draw.emit(desc)
	_finish_match()


func _finish_match() -> void:
	_simulation_context.paused = true
	EventBus.match_finished.emit(_winner, _loser, _elapsed_match_time)


func _transition_to(new_state: int) -> void:
	_current_state = new_state


func _build_conditions() -> void:
	_conditions.clear()
	for condition_data in _rules.victory_conditions:
		var condition: MatchCondition = _create_condition(condition_data)
		if condition != null:
			_conditions.append(condition)


func _create_condition(data: Dictionary) -> MatchCondition:
	var condition_type: String = data.get("type", "")
	match condition_type:
		"DestroyEnemyNexus":
			var cond := DestroyEnemyNexusCondition.new()
			cond.initialize(data)
			return cond
		"DestroyPlayerNexus":
			var cond := DestroyPlayerNexusCondition.new()
			cond.initialize(data)
			return cond
		"TimeLimit":
			var cond := TimeLimitCondition.new()
			var config: Dictionary = data.duplicate()
			config["time_limit"] = _rules.time_limit
			cond.initialize(config)
			return cond
	return null


func _build_condition_context() -> Dictionary:
	return {
		"nexus_system": _nexus_system,
		"elapsed_match_time": _elapsed_match_time,
		"simulation_context": _simulation_context,
	}
