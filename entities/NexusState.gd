class_name NexusState
extends RefCounted

var team: String = ""
var current_hp: int = 0
var max_hp: int = 0


static func create(p_team: String, p_max_hp: int) -> NexusState:
	var state := NexusState.new()
	state.team = p_team
	state.max_hp = p_max_hp
	state.current_hp = p_max_hp
	return state


func is_alive() -> bool:
	return current_hp > 0


func take_damage(amount: int) -> void:
	current_hp = max(0, current_hp - amount)


func get_hp_ratio() -> float:
	if max_hp <= 0:
		return 0.0
	return float(current_hp) / float(max_hp)
