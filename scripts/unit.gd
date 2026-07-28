class_name Unit
extends Node2D

const UNIT_WIDTH: float = 64.0
const UNIT_HEIGHT: float = 80.0
const IMAGE_HEIGHT: float = 64.0
const HP_BAR_HEIGHT: float = 6.0

var definition: Dictionary
var stats: UnitStats
var current_hp: int = 0
var unit_owner: String = "player"
var battle_group: BattleGroup = null
var current_state: int = UnitState.State.MOVING
var attack_cooldown: float = 0.0
var current_target: Unit = null
var active_effects: Array = []

var _direction: Vector2 = Vector2.ZERO
var _target_position: Vector2 = Vector2.ZERO
var _has_reached_target: bool = false
var _formation_target: Vector2 = Vector2.ZERO
var _has_formation_target: bool = false

var _hp_bar_fill: ColorRect
var _hp_label: Label


func _ready() -> void:
	_build_visual()


func initialize(card_data: Dictionary, p_owner: String = "player") -> void:
	definition = card_data
	unit_owner = p_owner
	stats = definition.get("stats", UnitStats.new())
	current_hp = stats.hp
	_apply_data()
	_update_state_label()
	_update_hp_display()


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
	return stats.range <= 1


func take_damage(amount: int) -> void:
	current_hp = max(0, current_hp - amount)
	_update_hp_display()
	EventBus.unit_damaged.emit(self, amount)
	if not is_alive():
		_set_state(UnitState.State.DEAD)
		EventBus.unit_died.emit(self)


func _physics_process(delta: float) -> void:
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
	_debug_position()


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


func _move_toward(target: Vector2, delta: float) -> void:
	var direction: Vector2 = (target - position).normalized()
	position += direction * stats.speed * delta


func _check_arrival() -> void:
	var distance_to_target: float = position.distance_to(_target_position)
	if distance_to_target < 2.0:
		_has_reached_target = true
		position = _target_position


func _debug_position() -> void:
	if Engine.is_editor_hint():
		return
	if int(position.x) % 100 == 0:
		print("Unit %s position: %v" % [definition.get("name", ""), position])


func _set_state(new_state: int) -> void:
	if current_state != new_state:
		current_state = new_state
		_update_state_label()


func _update_state_label() -> void:
	var state_label: Label = get_node_or_null("StateLabel")
	if state_label:
		state_label.text = UnitState.to_str(current_state)


func _update_hp_display() -> void:
	_update_hp_bar()
	_update_hp_label()


func _update_hp_bar() -> void:
	if _hp_bar_fill == null or stats == null or stats.hp <= 0:
		return
	var ratio: float = float(current_hp) / float(stats.hp)
	ratio = clamp(ratio, 0.0, 1.0)
	_hp_bar_fill.size.x = UNIT_WIDTH * ratio
	if ratio > 0.5:
		_hp_bar_fill.color = Color(0.2, 0.8, 0.2)
	elif ratio > 0.25:
		_hp_bar_fill.color = Color(0.8, 0.8, 0.2)
	else:
		_hp_bar_fill.color = Color(0.8, 0.2, 0.2)


func _update_hp_label() -> void:
	if _hp_label:
		_hp_label.text = "%d/%d" % [current_hp, stats.hp]


func _build_visual() -> void:
	var state_label := Label.new()
	state_label.name = "StateLabel"
	state_label.position = Vector2(0.0, -46.0)
	state_label.size = Vector2(UNIT_WIDTH, 16.0)
	state_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	state_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	state_label.add_theme_font_size_override("font_size", 10)
	state_label.add_theme_color_override("font_color", Color.YELLOW)
	add_child(state_label)

	var hp_label := Label.new()
	hp_label.name = "HPLabel"
	hp_label.position = Vector2(0.0, -30.0)
	hp_label.size = Vector2(UNIT_WIDTH, 16.0)
	hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hp_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hp_label.add_theme_font_size_override("font_size", 9)
	hp_label.add_theme_color_override("font_color", Color.WHITE)
	add_child(hp_label)
	_hp_label = hp_label

	var hp_bar_bg := ColorRect.new()
	hp_bar_bg.name = "HPBarBG"
	hp_bar_bg.position = Vector2(0.0, -14.0)
	hp_bar_bg.size = Vector2(UNIT_WIDTH, HP_BAR_HEIGHT)
	hp_bar_bg.color = Color(0.2, 0.2, 0.2, 0.8)
	add_child(hp_bar_bg)

	var hp_bar_fill := ColorRect.new()
	hp_bar_fill.name = "HPBarFill"
	hp_bar_fill.position = Vector2(0.0, -14.0)
	hp_bar_fill.size = Vector2(UNIT_WIDTH, HP_BAR_HEIGHT)
	hp_bar_fill.color = Color(0.2, 0.8, 0.2)
	add_child(hp_bar_fill)
	_hp_bar_fill = hp_bar_fill

	var background := ColorRect.new()
	background.size = Vector2(UNIT_WIDTH, UNIT_HEIGHT)
	background.color = Color(0.2, 0.2, 0.3, 1.0)
	add_child(background)

	var image := TextureRect.new()
	image.name = "UnitImage"
	image.size = Vector2(UNIT_WIDTH, IMAGE_HEIGHT)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(image)

	var label := Label.new()
	label.name = "UnitName"
	label.position = Vector2(0.0, IMAGE_HEIGHT)
	label.size = Vector2(UNIT_WIDTH, UNIT_HEIGHT - IMAGE_HEIGHT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 10)
	add_child(label)


func _apply_data() -> void:
	if definition.is_empty():
		return

	var label: Label = get_node("UnitName")
	label.text = definition.get("name", "")

	var image: TextureRect = get_node("UnitImage")
	var image_path: String = definition.get("image", "")
	if image_path != "" and ResourceLoader.exists(image_path):
		image.texture = load(image_path)
	else:
		image.texture = _create_placeholder(Vector2(UNIT_WIDTH, IMAGE_HEIGHT), Color(0.3, 0.3, 0.5))


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
