extends Node

signal battle_started
signal battle_ended
signal unit_spawned(unit: UnitInstance)
signal unit_moved(unit: UnitInstance)
signal unit_damaged(unit: UnitInstance, damage: int)
signal unit_died(unit: UnitInstance)
signal frontline_changed(group: BattleGroup)
signal target_changed(unit: UnitInstance, new_target: UnitInstance)
