class_name CombatSystem
extends Node

var _formation_system: FormationSystem
var _attack_system: AttackSystem
var _attack_timers: Dictionary


func initialize(formation_system: FormationSystem, attack_system: AttackSystem) -> void:
	_formation_system = formation_system
	_attack_system = attack_system
	_attack_timers = {}
	EventBus.unit_died.connect(_on_unit_died)


func _physics_process(delta: float) -> void:
	_cleanup_timers()
	for group in _formation_system.get_battle_groups():
		_process_group(group, delta)


func _cleanup_timers() -> void:
	var invalid_keys: Array = []
	for unit in _attack_timers:
		if not is_instance_valid(unit):
			invalid_keys.append(unit)
	for key in invalid_keys:
		_attack_timers.erase(key)


func _process_group(group: BattleGroup, delta: float) -> void:
	for unit in group.get_all_units():
		if not is_instance_valid(unit) or not unit.is_alive():
			continue
		_process_unit_combat(unit, delta)


func _process_unit_combat(unit: UnitInstance, delta: float) -> void:
	if not unit.is_melee():
		unit.set_blocked()
		return
	var target: UnitInstance = unit.get_current_target()
	if target != null and target.is_alive():
		unit.set_attacking()
		_update_attack_timer(unit, target, delta)
	else:
		unit.set_blocked()


func _update_attack_timer(attacker: UnitInstance, target: UnitInstance, delta: float) -> void:
	if not _attack_timers.has(attacker):
		_attack_timers[attacker] = 0.0
	_attack_timers[attacker] += delta
	var interval: float = 1.0 / attacker.definition.attack_speed
	if _attack_timers[attacker] >= interval:
		_attack_timers[attacker] = 0.0
		var result: DamageResult = _attack_system.execute(attacker, target)
		_apply_damage_result(result)


func _apply_damage_result(result: DamageResult) -> void:
	if result.target == null or not is_instance_valid(result.target):
		return
	if not result.target.is_alive():
		return
	result.target.take_damage(result.damage)


func _on_unit_died(unit: UnitInstance) -> void:
	_attack_timers.erase(unit)
