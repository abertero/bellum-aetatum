class_name DurationComponent
extends EffectComponent

const KEY_DURATION: String = "duration"
const KEY_REFRESH_POLICY: String = "refresh_policy"
const KEY_REMAINING: String = "remaining_time"

const REFRESH_DURATION_POLICY: String = "REFRESH_DURATION"
const NO_REFRESH_POLICY: String = "NO_REFRESH"


func initialize(config: Dictionary) -> void:
	super.initialize(config)
	component_type = "DurationComponent"


func update(delta: float, instance: EffectInstance) -> void:
	var remaining: float = _get_remaining(instance)
	if remaining <= 0.0:
		return
	remaining -= delta
	_set_remaining(instance, remaining)


func is_expired(instance: EffectInstance) -> bool:
	return _get_remaining(instance) <= 0.0


func get_remaining_duration(instance: EffectInstance) -> float:
	return _get_remaining(instance)


func get_initial_duration() -> float:
	return float(configuration.get(KEY_DURATION, 0.0))


func refresh_duration(instance: EffectInstance) -> void:
	var policy: String = configuration.get(KEY_REFRESH_POLICY, REFRESH_DURATION_POLICY)
	if policy == REFRESH_DURATION_POLICY:
		_set_remaining(instance, get_initial_duration())


func initialize_runtime(instance: EffectInstance) -> void:
	_set_remaining(instance, get_initial_duration())


func _get_remaining(instance: EffectInstance) -> float:
	return float(instance.runtime_state.get(KEY_REMAINING, 0.0))


func _set_remaining(instance: EffectInstance, value: float) -> void:
	instance.runtime_state[KEY_REMAINING] = value
