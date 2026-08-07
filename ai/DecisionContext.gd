class_name DecisionContext
extends RefCounted

var simulation_context: SimulationContext = null
var world_state: WorldState = null
var game_mode: GameModeDefinition = null
var ai_personality: AIPersonalityDefinition = null
var cached_perception: WorldState = null


static func create(
	p_simulation: SimulationContext,
	p_world_state: WorldState,
	p_game_mode: GameModeDefinition,
	p_personality: AIPersonalityDefinition
) -> DecisionContext:
	var ctx := DecisionContext.new()
	ctx.simulation_context = p_simulation
	ctx.world_state = p_world_state
	ctx.game_mode = p_game_mode
	ctx.ai_personality = p_personality
	return ctx


func set_cached_perception(perception: WorldState) -> void:
	cached_perception = perception


func get_cached_perception() -> WorldState:
	if cached_perception != null:
		return cached_perception
	return world_state


func get_personality_id() -> String:
	if ai_personality == null:
		return ""
	return ai_personality.id


func get_game_mode_id() -> String:
	if game_mode == null:
		return ""
	return game_mode.id


func get_elapsed_time() -> float:
	if simulation_context == null:
		return 0.0
	return simulation_context.elapsed_time


func get_resource_ratio() -> float:
	if world_state == null:
		return 0.0
	return world_state.get_resource_ratio()
