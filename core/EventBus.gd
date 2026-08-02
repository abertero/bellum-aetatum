extends Node

signal battle_started
signal battle_ended
signal unit_spawned(unit: UnitInstance)
signal unit_moved(unit: UnitInstance)
signal unit_died(unit: UnitInstance)
signal frontline_changed(group: BattleGroup)
signal target_changed(unit: UnitInstance, new_target: UnitInstance)
signal attack_started(attacker: UnitInstance, target: UnitInstance)
signal attack_finished(action: GameAction)
signal action_performed(action: GameAction)
