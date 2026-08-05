class_name DestroyEnemyNexusCondition
extends MatchCondition


func check(context: Dictionary) -> bool:
	var nexus_system: NexusSystem = context.get("nexus_system")
	if nexus_system == null:
		return false
	var enemy_nexus: NexusState = nexus_system.get_nexus("enemy")
	if enemy_nexus == null:
		return false
	return not enemy_nexus.is_alive()


func get_description() -> String:
	return "Destroy Enemy Nexus"
