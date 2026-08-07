class_name CommandRecord
extends RefCounted

var command_id: String = ""
var tick: int = 0
var source: String = ""
var command_type: String = ""
var payload: Dictionary = {}
var sequence_number: int = 0
var metadata: Dictionary = {}


static func from_command(command: GameCommand, p_sequence: int) -> CommandRecord:
	var record := CommandRecord.new()
	record.command_id = command.command_id
	record.tick = command.tick
	record.source = command.source
	record.command_type = command.get_command_type()
	record.payload = command.serialize()
	record.sequence_number = p_sequence
	record.metadata = command.metadata.duplicate()
	return record


func serialize() -> Dictionary:
	return {
		"command_id": command_id,
		"tick": tick,
		"source": source,
		"command_type": command_type,
		"payload": payload.duplicate(),
		"sequence_number": sequence_number,
		"metadata": metadata.duplicate(),
	}


static func deserialize(data: Dictionary) -> CommandRecord:
	var record := CommandRecord.new()
	record.command_id = str(data.get("command_id", ""))
	record.tick = int(data.get("tick", 0))
	record.source = str(data.get("source", ""))
	record.command_type = str(data.get("command_type", ""))
	var payload_data: Variant = data.get("payload", {})
	if payload_data is Dictionary:
		record.payload = payload_data.duplicate()
	record.sequence_number = int(data.get("sequence_number", 0))
	var meta_data: Variant = data.get("metadata", {})
	if meta_data is Dictionary:
		record.metadata = meta_data.duplicate()
	return record
