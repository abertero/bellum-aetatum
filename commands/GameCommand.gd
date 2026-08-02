class_name GameCommand
extends RefCounted

static var _next_id: int = 0

var command_id: String
var timestamp: float
var metadata: Dictionary


func _init(p_metadata: Dictionary = {}) -> void:
	_next_id += 1
	command_id = "cmd_%d" % _next_id
	timestamp = Time.get_ticks_msec() / 1000.0
	metadata = p_metadata.duplicate()
