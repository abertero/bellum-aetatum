class_name UnitStatsFactory
extends RefCounted


func create_from_dictionary(data: Dictionary) -> UnitStats:
	var hp: int = int(data.get("hp", 0))
	var attack: int = int(data.get("attack", 0))
	var range: int = int(data.get("range", 0))
	var speed: float = float(data.get("speed", 0.0))
	var cost: int = int(data.get("cost", 0))

	return UnitStats.new(hp, attack, range, speed, cost)
