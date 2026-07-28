extends Node

signal battle_started
signal battle_ended
signal unit_spawned(unit: Unit)
signal unit_moved(unit: Unit)
signal unit_damaged(unit: Unit, damage: int)
signal unit_died(unit: Unit)
signal frontline_changed(group: BattleGroup)
