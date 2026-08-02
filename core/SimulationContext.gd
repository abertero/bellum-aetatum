class_name SimulationContext
extends RefCounted

var delta_time: float = 0.0
var elapsed_time: float = 0.0
var time_scale: float = 1.0
var paused: bool = false


func update(delta: float) -> void:
	if paused:
		delta_time = 0.0
		return
	delta_time = delta * time_scale
	elapsed_time += delta_time
