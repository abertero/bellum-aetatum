class_name Unit
extends Node2D

const UNIT_WIDTH: float = 64.0
const UNIT_HEIGHT: float = 80.0
const IMAGE_HEIGHT: float = 64.0
const STATE_LABEL_HEIGHT: float = 20.0

var _card_data: Dictionary
var stats: UnitStats
var _team: String = "player"
var _direction: Vector2 = Vector2.ZERO
var _target_position: Vector2 = Vector2.ZERO
var _has_reached_target: bool = false

var _current_state: int = UnitState.State.MOVING
var _battle_group: BattleGroup = null
var _formation_target: Vector2 = Vector2.ZERO
var _has_formation_target: bool = false


func _ready() -> void:
	_build_visual()


func initialize(card_data: Dictionary, team: String = "player") -> void:
	_card_data = card_data
	_team = team
	stats = card_data.get("stats", UnitStats.new())
	_apply_data()
	_update_state_label()


func configure_movement(target_position: Vector2) -> void:
	_target_position = target_position
	_calculate_direction()


func get_current_state() -> int:
	return _current_state


func get_team() -> String:
	return _team


func set_battle_group(group: BattleGroup) -> void:
	_battle_group = group
	_set_state(UnitState.State.BLOCKED)


func set_formation_target(target: Vector2) -> void:
	_formation_target = target
	_has_formation_target = true
	if _current_state == UnitState.State.BLOCKED:
		_set_state(UnitState.State.WAITING)


func _physics_process(delta: float) -> void:
	match _current_state:
		UnitState.State.MOVING:
			_process_moving(delta)
		UnitState.State.WAITING:
			_process_waiting(delta)
		UnitState.State.BLOCKED:
			_process_blocked()
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
		print("Unit %s position: %v" % [_card_data.get("name", ""), position])


func _set_state(new_state: int) -> void:
	if _current_state != new_state:
		_current_state = new_state
		_update_state_label()


func _update_state_label() -> void:
	var state_label: Label = get_node_or_null("StateLabel")
	if state_label:
		state_label.text = UnitState.to_str(_current_state)


func _build_visual() -> void:
	var state_label := Label.new()
	state_label.name = "StateLabel"
	state_label.position = Vector2(0.0, -STATE_LABEL_HEIGHT)
	state_label.size = Vector2(UNIT_WIDTH, STATE_LABEL_HEIGHT)
	state_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	state_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	state_label.add_theme_font_size_override("font_size", 10)
	state_label.add_theme_color_override("font_color", Color.YELLOW)
	add_child(state_label)

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
	if _card_data.is_empty():
		return

	var label: Label = get_node("UnitName")
	label.text = _card_data.get("name", "")

	var image: TextureRect = get_node("UnitImage")
	var image_path: String = _card_data.get("image", "")
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
