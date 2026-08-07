class_name EffectInstance
extends RefCounted

enum State { ACTIVE, EXPIRED, REMOVED }

var instance_id: String = ""
var definition: EffectDefinition = null
var source: Variant = null
var owner: Variant = null
var stack_count: int = 1
var state: int = State.ACTIVE
var runtime_state: Dictionary = {}
var metadata: Dictionary = {}
var _components: Array[EffectComponent] = []


static func create(p_definition: EffectDefinition, p_owner: Variant, p_source: Variant) -> EffectInstance:
	var instance := EffectInstance.new()
	instance.instance_id = "effect_%s_%d" % [p_definition.id, _generate_id()]
	instance.definition = p_definition
	instance.owner = p_owner
	instance.source = p_source
	instance.stack_count = 1
	instance.state = State.ACTIVE
	instance._initialize_components()
	return instance


static var _counter: int = 0


static func _generate_id() -> int:
	EffectInstance._counter += 1
	return EffectInstance._counter


func _initialize_components() -> void:
	_components.clear()
	for component_data in definition.components:
		var component: EffectComponent = _create_component(component_data)
		if component != null:
			_components.append(component)


func _create_component(component_data: Dictionary) -> EffectComponent:
	var component_type: String = component_data.get("type", "")
	match component_type:
		"DurationComponent":
			var duration_comp := DurationComponent.new()
			duration_comp.initialize(component_data)
			return duration_comp
		"CombatModifierComponent":
			var modifier_comp := CombatModifierComponent.new()
			modifier_comp.initialize(component_data)
			return modifier_comp
	return null


func initialize_runtime() -> void:
	for component in _components:
		if component is DurationComponent:
			component.initialize_runtime(self)


func update(delta: float) -> void:
	if state != State.ACTIVE:
		return
	for component in _components:
		component.update(delta, self)
	_check_expiration()


func _check_expiration() -> void:
	for component in _components:
		if component.is_expired(self):
			state = State.EXPIRED
			return


func is_expired() -> bool:
	return state == State.EXPIRED


func is_active() -> bool:
	return state == State.ACTIVE


func refresh_duration() -> void:
	for component in _components:
		if component is DurationComponent:
			component.refresh_duration(self)
	state = State.ACTIVE


func add_stack() -> void:
	stack_count += 1


func remove() -> void:
	state = State.REMOVED


func get_modifiers() -> Array[CombatModifier]:
	var result: Array[CombatModifier] = []
	if not is_active():
		return result
	for component in _components:
		var modifiers: Array[CombatModifier] = component.get_modifiers(self)
		for modifier in modifiers:
			result.append(modifier)
	return result


func get_remaining_duration() -> float:
	for component in _components:
		if component is DurationComponent:
			return component.get_remaining_duration(self)
	return 0.0


func get_components() -> Array[EffectComponent]:
	return _components.duplicate()


func get_component_count() -> int:
	return _components.size()
