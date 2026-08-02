class_name GameAction
extends RefCounted

static var _next_id: int = 0

var action_id: String
var timestamp: float
var source: Node
var target: Node
var metadata: Dictionary


func _init(p_source: Node = null, p_target: Node = null, p_metadata: Dictionary = {}) -> void:
	_next_id += 1
	action_id = "action_%d" % _next_id
	timestamp = Time.get_ticks_msec() / 1000.0
	source = p_source
	target = p_target
	metadata = p_metadata.duplicate()
