class_name AbilitySystem
extends Node

var _registry: AbilityRegistry = null
var _simulation_context: SimulationContext = null
var _effect_system: EffectSystem = null
var _projectile_registry: ProjectileDefinitionRegistry = null
var _command_dispatcher: CommandDispatcher = null
var _parent_node: Node = null
var _cooldowns: Dictionary = {}
var _last_execution: AbilityInstance = null
var _pipeline_executor: AbilityPipelineExecutor = null


func initialize(registry: AbilityRegistry, simulation_context: SimulationContext) -> void:
	_registry = registry
	_simulation_context = simulation_context
	_pipeline_executor = AbilityPipelineExecutor.new()


func set_effect_system(effect_system: EffectSystem) -> void:
	_effect_system = effect_system


func set_projectile_registry(registry: ProjectileDefinitionRegistry) -> void:
	_projectile_registry = registry


func set_command_dispatcher(dispatcher: CommandDispatcher) -> void:
	_command_dispatcher = dispatcher


func set_parent_node(parent: Node) -> void:
	_parent_node = parent


func _physics_process(_delta: float) -> void:
	_update_cooldowns()


func execute_ability(ability_id: String, caster: UnitInstance, target: Variant = null) -> bool:
	if not _can_execute(ability_id, caster):
		return false

	var definition: AbilityDefinition = _registry.get_ability(ability_id)
	if definition == null:
		return false

	_start_cooldown(caster, ability_id, definition.cooldown)
	var instance: AbilityInstance = AbilityInstance.create(definition, caster)
	_last_execution = instance

	EventBus.ability_started.emit(instance)

	var commands: Array[GameCommand] = _execute_pipeline(definition, caster, target, instance)
	_dispatch_commands(commands)

	EventBus.ability_finished.emit(instance)
	return true


func is_ability_ready(ability_id: String, owner: UnitInstance) -> bool:
	if not _cooldowns.has(owner):
		return true
	var owner_cooldowns: Dictionary = _cooldowns[owner]
	if not owner_cooldowns.has(ability_id):
		return true
	return owner_cooldowns[ability_id] <= 0.0


func get_remaining_cooldown(ability_id: String, owner: UnitInstance) -> float:
	if not _cooldowns.has(owner):
		return 0.0
	var owner_cooldowns: Dictionary = _cooldowns[owner]
	if not owner_cooldowns.has(ability_id):
		return 0.0
	return max(0.0, owner_cooldowns[ability_id])


func get_last_execution() -> AbilityInstance:
	return _last_execution


func _can_execute(ability_id: String, caster: UnitInstance) -> bool:
	if _registry == null:
		return false
	if caster == null or not is_instance_valid(caster):
		return false
	if not is_ability_ready(ability_id, caster):
		return false
	return _registry.has_ability(ability_id)


func _execute_pipeline(
	definition: AbilityDefinition,
	caster: UnitInstance,
	target: Variant,
	instance: AbilityInstance
) -> Array[GameCommand]:
	if definition.pipeline == null:
		return []
	var context: Dictionary = _build_context()
	return _pipeline_executor.execute(definition.pipeline, caster, target, context, instance)


func _build_context() -> Dictionary:
	return {
		"effect_system": _effect_system,
		"projectile_registry": _projectile_registry,
		"command_dispatcher": _command_dispatcher,
		"parent_node": _parent_node,
		"simulation_context": _simulation_context,
	}


func _dispatch_commands(commands: Array[GameCommand]) -> void:
	if _command_dispatcher == null:
		return
	for command in commands:
		_command_dispatcher.dispatch(command)


func _start_cooldown(owner: UnitInstance, ability_id: String, duration: float) -> void:
	if duration <= 0.0:
		return
	if not _cooldowns.has(owner):
		_cooldowns[owner] = {}
	_cooldowns[owner][ability_id] = duration
	EventBus.ability_cooldown_started.emit(ability_id, owner, duration)


func _update_cooldowns() -> void:
	if _simulation_context == null:
		return
	var delta: float = _simulation_context.delta_time
	var owners_to_erase: Array = []

	for owner in _cooldowns:
		if not is_instance_valid(owner):
			owners_to_erase.append(owner)
			continue
		var owner_cooldowns: Dictionary = _cooldowns[owner]
		var abilities_to_erase: Array = []
		for ability_id in owner_cooldowns:
			owner_cooldowns[ability_id] -= delta
			if owner_cooldowns[ability_id] <= 0.0:
				EventBus.ability_ready.emit(ability_id, owner)
				abilities_to_erase.append(ability_id)
		for ability_id in abilities_to_erase:
			owner_cooldowns.erase(ability_id)
		if owner_cooldowns.is_empty():
			owners_to_erase.append(owner)

	for owner in owners_to_erase:
		_cooldowns.erase(owner)
