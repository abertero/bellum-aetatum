class_name CommandLog
extends RefCounted

var _records: Array[CommandRecord] = []
var _sequence_counter: int = 0


func record(command: GameCommand) -> CommandRecord:
	var record: CommandRecord = CommandRecord.from_command(command, _sequence_counter)
	_records.append(record)
	_sequence_counter += 1
	return record


func get_records() -> Array[CommandRecord]:
	return _records.duplicate()


func get_records_for_tick(p_tick: int) -> Array[CommandRecord]:
	var result: Array[CommandRecord] = []
	for record in _records:
		if record.tick == p_tick:
			result.append(record)
	return result


func get_record_count() -> int:
	return _records.size()


func get_last_sequence() -> int:
	return _sequence_counter


func clear() -> void:
	_records.clear()
	_sequence_counter = 0


func serialize() -> Array:
	var result: Array = []
	for record in _records:
		result.append(record.serialize())
	return result


func deserialize(data: Array) -> void:
	_records.clear()
	_sequence_counter = 0
	for entry in data:
		if entry is Dictionary:
			var record: CommandRecord = CommandRecord.deserialize(entry)
			_records.append(record)
			if record.sequence_number >= _sequence_counter:
				_sequence_counter = record.sequence_number + 1
