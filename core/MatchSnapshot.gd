class_name MatchSnapshot
extends RefCounted

var simulation_tick: int = 0
var elapsed_time: float = 0.0
var random_seed: int = 0
var match_state: int = 0
var world_state: Dictionary = {}
var economy_state: Dictionary = {}
var active_effects: Array = []
var active_projectiles: Array = []
var active_units: Array = []
var cooldowns: Dictionary = {}
var command_sequence: int = 0
var content_version: String = ""
var game_mode_id: String = ""


func serialize() -> Dictionary:
	return {
		"simulation_tick": simulation_tick,
		"elapsed_time": elapsed_time,
		"random_seed": random_seed,
		"match_state": match_state,
		"world_state": world_state.duplicate(true),
		"economy_state": economy_state.duplicate(true),
		"active_effects": active_effects.duplicate(true),
		"active_projectiles": active_projectiles.duplicate(true),
		"active_units": active_units.duplicate(true),
		"cooldowns": cooldowns.duplicate(true),
		"command_sequence": command_sequence,
		"content_version": content_version,
		"game_mode_id": game_mode_id,
	}


static func deserialize(data: Dictionary) -> MatchSnapshot:
	var snapshot := MatchSnapshot.new()
	snapshot.simulation_tick = int(data.get("simulation_tick", 0))
	snapshot.elapsed_time = float(data.get("elapsed_time", 0.0))
	snapshot.random_seed = int(data.get("random_seed", 0))
	snapshot.match_state = int(data.get("match_state", 0))
	var ws: Variant = data.get("world_state", {})
	if ws is Dictionary:
		snapshot.world_state = ws.duplicate(true)
	var es: Variant = data.get("economy_state", {})
	if es is Dictionary:
		snapshot.economy_state = es.duplicate(true)
	var ae: Variant = data.get("active_effects", [])
	if ae is Array:
		snapshot.active_effects = ae.duplicate(true)
	var ap: Variant = data.get("active_projectiles", [])
	if ap is Array:
		snapshot.active_projectiles = ap.duplicate(true)
	var au: Variant = data.get("active_units", [])
	if au is Array:
		snapshot.active_units = au.duplicate(true)
	var cd: Variant = data.get("cooldowns", {})
	if cd is Dictionary:
		snapshot.cooldowns = cd.duplicate(true)
	snapshot.command_sequence = int(data.get("command_sequence", 0))
	snapshot.content_version = str(data.get("content_version", ""))
	snapshot.game_mode_id = str(data.get("game_mode_id", ""))
	return snapshot
