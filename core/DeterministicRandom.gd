class_name DeterministicRandom
extends RefCounted

const _A: int = 1664525
const _C: int = 1013904223
const _M: int = 4294967296

var _state: int = 0


func initialize(seed: int) -> void:
	_state = seed & 0xFFFFFFFF


func next_int() -> int:
	_state = ((_A * _state + _C) & 0xFFFFFFFF)
	return _state


func next_int_range(low: int, high: int) -> int:
	if high <= low:
		return low
	var range_size: int = high - low
	return low + (next_int() % range_size)


func next_float() -> float:
	return float(next_int() & 0xFFFFFFFF) / float(_M)


func next_float_range(low: float, high: float) -> float:
	return low + next_float() * (high - low)


func next_bool() -> bool:
	return (next_int() & 1) == 1


func select_from(items: Array) -> Variant:
	if items.is_empty():
		return null
	var index: int = next_int() % items.size()
	return items[index]


func get_seed() -> int:
	return _state
