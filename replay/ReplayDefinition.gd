class_name ReplayDefinition
extends RefCounted

var format_version: String = "1.0.0"
var engine_version: String = "1.0.0"
var content_version: String = ""
var game_mode_id: String = ""
var random_seed: int = 0
var initial_snapshot: MatchSnapshot = null
var command_log: Array = []
var final_tick: int = 0
var metadata: Dictionary = {}


func serialize() -> Dictionary:
	return {
		"format_version": format_version,
		"engine_version": engine_version,
		"content_version": content_version,
		"game_mode_id": game_mode_id,
		"random_seed": random_seed,
		"initial_snapshot": initial_snapshot.serialize() if initial_snapshot != null else {},
		"command_log": command_log.duplicate(true),
		"final_tick": final_tick,
		"metadata": metadata.duplicate(true),
	}


static func deserialize(data: Dictionary) -> ReplayDefinition:
	var replay := ReplayDefinition.new()
	replay.format_version = str(data.get("format_version", "1.0.0"))
	replay.engine_version = str(data.get("engine_version", "1.0.0"))
	replay.content_version = str(data.get("content_version", ""))
	replay.game_mode_id = str(data.get("game_mode_id", ""))
	replay.random_seed = int(data.get("random_seed", 0))
	var snap_data: Variant = data.get("initial_snapshot", {})
	if snap_data is Dictionary:
		replay.initial_snapshot = MatchSnapshot.deserialize(snap_data)
	var cmd_data: Variant = data.get("command_log", [])
	if cmd_data is Array:
		replay.command_log = cmd_data.duplicate(true)
	replay.final_tick = int(data.get("final_tick", 0))
	var meta: Variant = data.get("metadata", {})
	if meta is Dictionary:
		replay.metadata = meta.duplicate(true)
	return replay


func to_json() -> String:
	return JSON.stringify(serialize(), "  ")


static func from_json(json_string: String) -> ReplayDefinition:
	var parsed: Variant = JSON.parse_string(json_string)
	if parsed is Dictionary:
		return ReplayDefinition.deserialize(parsed)
	return null
