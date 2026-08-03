class_name CombatSystem
extends Node

var _command_dispatcher: CommandDispatcher
var _attack_timers: Dictionary
var _tracked_units: Array[UnitInstance] = []


func initialize(command_dispatcher: CommandDispatcher) -> void:
	_command_dispatcher = command_dispatcher
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
	action.target.take_damage(action.damage)
	EventBus.action_performed.emit(action)


func _on_unit_spawned(unit: UnitInstance) -> void:
	_tracked_units.append(unit)


func _on_unit_died(unit: UnitInstance) -> void:
	_tracked_units.erase(unit)
	_attack_timers.erase(unit)
