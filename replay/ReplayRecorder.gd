class_name ReplayRecorder
extends RefCounted

var _command_log: CommandLog = null
var _initial_snapshot: MatchSnapshot = null
var _content_version: String = ""
var _game_mode_id: String = ""
var _random_seed: int = 0
var _recording: bool = false
var _checkpoint_interval: int = 300
var _last_checkpoint_tick: int = 0
var _checkpoints: Dictionary = {}


func initialize(
	p_command_log: CommandLog,
	p_seed: int,
	p_content_version: String,
	p_game_mode_id: String
) -> void:
	_command_log = p_command_log
	_random_seed = p_seed
	_content_version = p_content_version
	_game_mode_id = p_game_mode_id


func set_checkpoint_interval(interval: int) -> void:
	_checkpoint_interval = interval


func start_recording(snapshot: MatchSnapshot) -> void:
	_initial_snapshot = snapshot
	_recording = true
	_last_checkpoint_tick = snapshot.simulation_tick


func stop_recording(final_tick: int) -> ReplayDefinition:
	_recording = false
	var replay := ReplayDefinition.new()
	replay.content_version = _content_version
	replay.game_mode_id = _game_mode_id
	replay.random_seed = _random_seed
	replay.initial_snapshot = _initial_snapshot
	replay.command_log = _command_log.serialize()
	replay.final_tick = final_tick
	return replay


func is_recording() -> bool:
	return _recording


func record_command(command: GameCommand) -> void:
	if not _recording:
		return
	_command_log.record(command)


func maybe_checkpoint(current_tick: int, snapshot_func: Callable) -> void:
	if not _recording:
		return
	if current_tick - _last_checkpoint_tick < _checkpoint_interval:
		return
	_last_checkpoint_tick = current_tick
	if snapshot_func.is_valid():
		_checkpoints[current_tick] = snapshot_func.call()


func get_checkpoint(tick: int) -> MatchSnapshot:
	if _checkpoints.has(tick):
		return _checkpoints[tick]
	return null


func get_checkpoint_ticks() -> Array:
	return _checkpoints.keys()
