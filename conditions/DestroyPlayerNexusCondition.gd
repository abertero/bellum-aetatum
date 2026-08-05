class_name DestroyPlayerNexusCondition
extends MatchCondition


func check(context: Dictionary) -> bool:
	var nexus_system: NexusSystem = context.get("nexus_system")
	if nexus_system == null:
		return false
	var player_nexus: NexusState = nexus_system.get_nexus("player")
	if player_nexus == null:
		return false
	return not player_nexus.is_alive()


func get_description() -> String:
	return "Destroy Player Nexus"
