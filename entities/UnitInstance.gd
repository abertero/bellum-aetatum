class_name UnitInstance
extends Node2D

var definition: UnitDefinition
var current_hp: int = 0
var unit_owner: String = "player"
var battle_group: BattleGroup = null
var current_state: int = UnitState.State.MOVING
var attack_cooldown: float = 0.0
var current_target: Variant = null
var active_effects: Array = []

var _direction: Vector2 = Vector2.ZERO
var _target_position: Vector2 = Vector2.ZERO
var _has_reached_target: bool = false
var _formation_target: Vector2 = Vector2.ZERO
var _has_formation_target: bool = false
var _visual: UnitVisualComponent


func _ready() -> void:
	_visual = UnitVisualComponent.new()
	_visual.build_visuals(self)
	add_child(_visual)


func initialize(card_definition: UnitDefinition, p_owner: String = "player") -> void:
	definition = card_definition
	unit_owner = p_owner
	current_hp = definition.hp
	_apply_data()
	_update_state_label()
	_visual.update_hp_display(current_hp, definition.hp)


func configure_movement(target_position: Vector2) -> void:
	_target_position = target_position
	_calculate_direction()


func set_battle_group(group: BattleGroup) -> void:
	battle_group = group
	_set_state(UnitState.State.BLOCKED)


func set_formation_target(target: Vector2) -> void:
	_formation_target = target
	_has_formation_target = true
	if current_state == UnitState.State.BLOCKED:
		_set_state(UnitState.State.WAITING)


func set_attacking() -> void:
	if current_state != UnitState.State.ATTACKING:
		_set_state(UnitState.State.ATTACKING)


func set_blocked() -> void:
	if current_state == UnitState.State.ATTACKING:
		_set_state(UnitState.State.BLOCKED)


func is_alive() -> bool:
	return current_hp > 0


func is_melee() -> bool:
	return definition.attack_model == "melee"


func take_damage(amount: int) -> void:
	current_hp = max(0, current_hp - amount)
	_visual.update_hp_display(current_hp, definition.hp)
	if not is_alive():
		_set_state(UnitState.State.DEAD)
		EventBus.unit_died.emit(self)


func get_current_target() -> UnitInstance:
	if is_instance_valid(current_target):
		return current_target as UnitInstance
	return null


func is_target_valid() -> bool:
	return is_instance_valid(current_target) and current_target.is_alive()


func _physics_process(delta: float) -> void:
	_validate_target()
	_visual.update_target_display(get_current_target())
	match current_state:
		UnitState.State.MOVING:
			_process_moving(delta)
		UnitState.State.WAITING:
			_process_waiting(delta)
		UnitState.State.BLOCKED:
			_process_blocked()
		UnitState.State.ATTACKING:
			_process_attacking()
		UnitState.State.DEAD:
			_process_dead()


func _process_moving(delta: float) -> void:
	if _has_reached_target:
		return
	if _has_formation_target:
		_move_toward(_formation_target, delta)
	else:
		_move_toward(_target_position, delta)
	_check_arrival()


func _process_waiting(delta: float) -> void:
	if _has_formation_target:
		var distance_to_formation: float = position.distance_to(_formation_target)
		if distance_to_formation < 2.0:
			_set_state(UnitState.State.BLOCKED)
			position = _formation_target
		else:
			_move_toward(_formation_target, delta)


func _process_blocked() -> void:
	pass


func _process_attacking() -> void:
	pass


func _process_dead() -> void:
	pass


func _validate_target() -> void:
	if current_target != null and not is_instance_valid(current_target):
		current_target = null


func _move_toward(target: Vector2, delta: float) -> void:
	var direction: Vector2 = (target - position).normalized()
	position += direction * definition.speed * delta


func _check_arrival() -> void:
	var distance_to_target: float = position.distance_to(_target_position)
	if distance_to_target < 2.0:
		_has_reached_target = true
		position = _target_position


func _set_state(new_state: int) -> void:
	if current_state != new_state:
		current_state = new_state
		_update_state_label()


func _update_state_label() -> void:
	var state_label: Label = get_node_or_null("StateLabel")
	if state_label:
		state_label.text = UnitState.to_str(current_state)


func _apply_data() -> void:
	if definition == null:
		return
	var label: Label = get_node("UnitName")
	label.text = definition.name
	var image: TextureRect = get_node("UnitImage")
	var image_path: String = definition.image
	if image_path != "" and ResourceLoader.exists(image_path):
		image.texture = load(image_path)
	else:
		image.texture = _create_placeholder(Vector2(64, 64), Color(0.3, 0.3, 0.5))


func _calculate_direction() -> void:
	var diff: Vector2 = _target_position - position
	if diff.length() > 0.0:
		_direction = diff.normalized()
	else:
		_direction = Vector2.RIGHT
		_has_reached_target = true


func _create_placeholder(size: Vector2, color: Color) -> ImageTexture:
	var img := Image.create(int(size.x), int(size.y), false, Image.FORMAT_RGBA8)
	img.fill(color)
	return ImageTexture.create_from_image(img)
