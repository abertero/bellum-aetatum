class_name SimulationContext
extends RefCounted

var tick: int = 0
var fixed_delta_time: float = 1.0 / 30.0
var delta_time: float = 0.0
var elapsed_time: float = 0.0
var time_scale: float = 1.0
var paused: bool = false
var random_seed: int = 0
var accumulator: float = 0.0

var _random: DeterministicRandom = null
var _next_entity_id: int = 0


func initialize(seed: int, p_fixed_delta: float = 1.0 / 30.0) -> void:
	random_seed = seed
	fixed_delta_time = p_fixed_delta
	_random = DeterministicRandom.new()
	_random.initialize(seed)
	_next_entity_id = 0


func update(frame_delta: float) -> void:
	if paused:
		delta_time = 0.0
		return
	delta_time = 0.0
	accumulator += frame_delta * time_scale


func consume_tick() -> bool:
	if paused:
		delta_time = 0.0
		return false
	if accumulator < fixed_delta_time:
		return false
	accumulator -= fixed_delta_time
	delta_time = fixed_delta_time
	elapsed_time += fixed_delta_time
	tick += 1
	return true


func get_random() -> DeterministicRandom:
	return _random


func next_entity_id() -> int:
	_next_entity_id += 1
	return _next_entity_id


func reset_accumulator() -> void:
	accumulator = 0.0
