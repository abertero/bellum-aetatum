class_name UnitStats
extends RefCounted

var hp: int = 0
var attack: int = 0
var range: int = 0
var speed: float = 0.0
var cost: int = 0


func _init(
	p_hp: int = 0,
	p_attack: int = 0,
	p_range: int = 0,
	p_speed: float = 0.0,
	p_cost: int = 0
) -> void:
	hp = p_hp
	attack = p_attack
	range = p_range
	speed = p_speed
	cost = p_cost
