class_name TargetingSystem
extends Node

var _formation_system: FormationSystem


func initialize(formation_system: FormationSystem) -> void:
	_formation_system = formation_system


func _physics_process(_delta: float) -> void:
	for group in _formation_system.get_battle_groups():
		_update_targets_for_group(group)


func _update_targets_for_group(group: BattleGroup) -> void:
	_assign_targets_for_team(group, "player")
	_assign_targets_for_team(group, "enemy")


func _assign_targets_for_team(group: BattleGroup, team: String) -> void:
	var formation: Array[UnitInstance] = group.player_formation if team == "player" else group.enemy_formation
	for unit in formation:
		if not is_instance_valid(unit) or not unit.is_alive():
			continue
		if not unit.is_melee():
			continue
		var target: UnitInstance = group.get_next_target(unit)
		_assign_target(unit, target)


func _assign_target(unit: UnitInstance, target: UnitInstance) -> void:
	var old_target: UnitInstance = unit.get_current_target()
	if old_target != target:
		unit.current_target = target
		EventBus.target_changed.emit(unit, target)
