class_name CombatSystem
extends Node

var _formation_system: FormationSystem
var _attack_timers: Dictionary


func initialize(formation_system: FormationSystem) -> void:
	_formation_system = formation_system
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
	group.cleanup()

	var allied_frontline: UnitInstance = group.get_frontline_allied()
	var enemy_frontline: UnitInstance = group.get_frontline_enemy()

	var combat_active: bool = false
	if allied_frontline != null and enemy_frontline != null:
		if allied_frontline.is_melee() and enemy_frontline.is_melee():
			combat_active = true

	if not combat_active:
		_reset_non_combat_units(group)
		return

	_process_melee_units(group.allied_units, enemy_frontline, delta)
	_process_melee_units(group.enemy_units, allied_frontline, delta)


func _reset_non_combat_units(group: BattleGroup) -> void:
	for unit in group.allied_units:
		if is_instance_valid(unit) and unit.is_alive():
			unit.set_blocked()
	for unit in group.enemy_units:
		if is_instance_valid(unit) and unit.is_alive():
			unit.set_blocked()


func _process_melee_units(units: Array[UnitInstance], target: UnitInstance, delta: float) -> void:
	for unit in units:
		if not is_instance_valid(unit) or not unit.is_alive():
			continue
		if not unit.is_melee():
			continue
		unit.set_attacking()
		_update_attack_timer(unit, target, delta)


func _update_attack_timer(attacker: UnitInstance, target: UnitInstance, delta: float) -> void:
	if not _attack_timers.has(attacker):
		_attack_timers[attacker] = 0.0

	_attack_timers[attacker] += delta
	var interval: float = 1.0 / attacker.definition.attack_speed

	if _attack_timers[attacker] >= interval:
		_attack_timers[attacker] = 0.0
		_apply_damage(attacker, target)


func _apply_damage(attacker: UnitInstance, target: UnitInstance) -> void:
	if not is_instance_valid(target) or not target.is_alive():
		return
	var damage: int = attacker.definition.attack
	target.take_damage(damage)


func _on_unit_died(unit: UnitInstance) -> void:
	_attack_timers.erase(unit)
	var group: BattleGroup = unit.battle_group
	if group != null:
		group.remove_unit(unit)
	unit.queue_free()
