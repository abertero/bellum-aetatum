class_name ReplayPlayer
extends RefCounted

var _replay: ReplayDefinition = null
var _current_tick: int = 0
var _playing: bool = false
var _command_index: int = 0
var _commands: Array[CommandRecord] = []


func load_replay(p_replay: ReplayDefinition) -> bool:
	if p_replay == null:
		return false
	if p_replay.initial_snapshot == null:
		return false
	_replay = p_replay
	_current_tick = 0
	_command_index = 0
	_playing = false
	_commands.clear()
	for entry in _replay.command_log:
		if entry is Dictionary:
			_commands.append(CommandRecord.deserialize(entry))
	return true


func get_initial_snapshot() -> MatchSnapshot:
	if _replay == null:
		return null
	return _replay.initial_snapshot


func get_random_seed() -> int:
	if _replay == null:
		return 0
	return _replay.random_seed


func get_content_version() -> String:
	if _replay == null:
		return ""
	return _replay.content_version


func get_game_mode_id() -> String:
	if _replay == null:
		return ""
	return _replay.game_mode_id


func get_final_tick() -> int:
	if _replay == null:
		return 0
	return _replay.final_tick


func start_playback() -> void:
	_playing = true
	_current_tick = 0
	_command_index = 0


func stop_playback() -> void:
	_playing = false


func is_playing() -> bool:
	return _playing


func get_current_tick() -> int:
	return _current_tick


func get_commands_for_tick(tick: int) -> Array[CommandRecord]:
	var result: Array[CommandRecord] = []
	for record in _commands:
		if record.tick == tick:
			result.append(record)
	return result


func advance_tick() -> Array[CommandRecord]:
	var cmds: Array[CommandRecord] = get_commands_for_tick(_current_tick)
	_current_tick += 1
	return cmds


func has_finished() -> bool:
	if _replay == null:
		return true
	return _current_tick > _replay.final_tick


func get_progress() -> float:
	if _replay == null or _replay.final_tick <= 0:
		return 0.0
	return float(_current_tick) / float(_replay.final_tick)


func get_total_commands() -> int:
	return _commands.size()
