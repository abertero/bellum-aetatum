class_name CombatSystem
extends Node

var _command_dispatcher: CommandDispatcher
var _affinity_rule_system: AffinityRuleSystem
var _effect_system: EffectSystem = null
var _attack_timers: Dictionary
var _tracked_units: Array[UnitInstance] = []


func initialize(command_dispatcher: CommandDispatcher, affinity_rule_system: AffinityRuleSystem, effect_system: EffectSystem = null) -> void:
	_command_dispatcher = command_dispatcher
	_affinity_rule_system = affinity_rule_system
	_effect_system = effect_system
	_attack_timers = {}
	EventBus.unit_spawned.connect(_on_unit_spawned)
	EventBus.unit_died.connect(_on_unit_died)


func _physics_process(delta: float) -> void:
	_cleanup_timers()
	_cleanup_tracked_units()
	_process_all_units(delta)


func _cleanup_timers() -> void:
	var invalid_keys: Array = []
	for unit in _attack_timers:
		if not is_instance_valid(unit):
			invalid_keys.append(unit)
	for key in invalid_keys:
		_attack_timers.erase(key)


func _cleanup_tracked_units() -> void:
	var valid: Array[UnitInstance] = []
	for unit in _tracked_units:
		if is_instance_valid(unit) and unit.is_alive():
			valid.append(unit)
	_tracked_units = valid


func _process_all_units(delta: float) -> void:
	var units: Array[UnitInstance] = _tracked_units.duplicate()
	for unit in units:
		if not is_instance_valid(unit) or not unit.is_alive():
			continue
		if unit.is_melee() and unit.battle_group == null:
			continue
		_process_unit_combat(unit, delta)


func _process_unit_combat(unit: UnitInstance, delta: float) -> void:
	if unit.is_melee():
		_process_melee_combat(unit, delta)
	elif unit.is_ranged():
		_process_ranged_combat(unit, delta)
	else:
		unit.set_blocked()


func _process_melee_combat(unit: UnitInstance, delta: float) -> void:
	var target: UnitInstance = unit.get_current_target()
	if target != null and target.is_alive():
		unit.set_attacking()
		_update_attack_timer(unit, target, delta)
	else:
		unit.set_moving()


func _process_ranged_combat(unit: UnitInstance, delta: float) -> void:
	var target: UnitInstance = unit.get_current_target()
	if target != null and target.is_alive():
		unit.set_attacking()
		_update_attack_timer(unit, target, delta)
	else:
		unit.set_moving()


func _update_attack_timer(attacker: UnitInstance, target: UnitInstance, delta: float) -> void:
	if not _attack_timers.has(attacker):
		_attack_timers[attacker] = 0.0
	_attack_timers[attacker] += delta
	var interval: float = 1.0 / attacker.definition.attack_speed
	if _attack_timers[attacker] >= interval:
		_attack_timers[attacker] = 0.0
		var command: AttackCommand = AttackCommand.create(attacker, target)
		var action: DamageAction = _command_dispatcher.dispatch(command) as DamageAction
		_apply_damage_action(action)


func _apply_damage_action(action: DamageAction) -> void:
	if action.target == null or not is_instance_valid(action.target):
		return
	if not action.target.is_alive():
		return
	if action.damage <= 0:
		return
	
	var final_damage: int = _calculate_final_damage(action)
	action.target.take_damage(final_damage)
	EventBus.action_performed.emit(action)


func _calculate_final_damage(action: DamageAction) -> int:
	var base_damage: float = float(action.damage)
	
	if action.source == null or not is_instance_valid(action.source):
		return int(base_damage)
	if action.target == null or not is_instance_valid(action.target):
		return int(base_damage)
	
	var all_modifiers := CombatModifierCollection.new()
	
	var attacker_affinity: String = action.source.definition.affinity_id
	var defender_affinity: String = action.target.definition.affinity_id
	
	if attacker_affinity != "" and defender_affinity != "":
		var affinity_modifiers: CombatModifierCollection = _affinity_rule_system.get_attack_modifiers(attacker_affinity, defender_affinity)
		all_modifiers.add_modifiers(affinity_modifiers.get_modifiers())
	
	if _effect_system != null:
		var effect_mods: Array[CombatModifier] = _effect_system.get_modifiers(action.source)
		all_modifiers.add_modifiers(effect_mods)
		var defense_mods: Array[CombatModifier] = _effect_system.get_modifiers(action.target)
		all_modifiers.add_modifiers(defense_mods)
	
	if all_modifiers.is_empty():
		return int(base_damage)
	
	var final_damage: float = all_modifiers.apply_to(base_damage)
	
	if attacker_affinity != "" and defender_affinity != "":
		EventBus.affinity_debug.emit(attacker_affinity, defender_affinity, all_modifiers, int(final_damage))
	
	return int(final_damage)


func _on_unit_spawned(unit: UnitInstance) -> void:
	_tracked_units.append(unit)


func _on_unit_died(unit: UnitInstance) -> void:
	_tracked_units.erase(unit)
	_attack_timers.erase(unit)
