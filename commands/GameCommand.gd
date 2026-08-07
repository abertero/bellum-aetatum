class_name GameCommand
extends RefCounted

var command_id: String = ""
var tick: int = 0
var source: String = ""
var metadata: Dictionary = {}


func _init() -> void:
	pass


func get_command_type() -> String:
	return "GameCommand"


func serialize() -> Dictionary:
	return {
		"command_id": command_id,
		"tick": tick,
		"source": source,
		"command_type": get_command_type(),
		"metadata": metadata.duplicate(),
	}


func deserialize(data: Dictionary) -> void:
	command_id = str(data.get("command_id", ""))
	tick = int(data.get("tick", 0))
	source = str(data.get("source", ""))
	metadata = data.get("metadata", {}).duplicate()
