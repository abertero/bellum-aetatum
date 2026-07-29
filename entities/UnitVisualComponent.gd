class_name UnitVisualComponent
extends Node

const UNIT_WIDTH: float = 64.0
const UNIT_HEIGHT: float = 80.0
const IMAGE_HEIGHT: float = 64.0
const HP_BAR_HEIGHT: float = 6.0

var _hp_bar_fill: ColorRect
var _hp_label: Label
var _previous_target: UnitInstance = null


func build_visuals(unit: UnitInstance) -> void:
	_build_debug_labels(unit)
	_build_hp_bar(unit)
	_build_unit_display(unit)


func get_hp_bar_fill() -> ColorRect:
	return _hp_bar_fill


func get_hp_label() -> Label:
	return _hp_label


func update_hp_display(current_hp: int, max_hp: int) -> void:
	_update_hp_bar(current_hp, max_hp)
	_update_hp_label(current_hp, max_hp)


func update_target_display(current_target: UnitInstance) -> void:
	if current_target != _previous_target:
		_previous_target = current_target
		_update_target_label(current_target)


func _build_debug_labels(unit: UnitInstance) -> void:
	var target_label := Label.new()
	target_label.name = "TargetLabel"
	target_label.position = Vector2(0.0, -62.0)
	target_label.size = Vector2(UNIT_WIDTH, 16.0)
	target_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	target_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	target_label.add_theme_font_size_override("font_size", 9)
	target_label.add_theme_color_override("font_color", Color.CYAN)
	unit.add_child(target_label)

	var state_label := Label.new()
	state_label.name = "StateLabel"
	state_label.position = Vector2(0.0, -46.0)
	state_label.size = Vector2(UNIT_WIDTH, 16.0)
	state_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	state_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	state_label.add_theme_font_size_override("font_size", 10)
	state_label.add_theme_color_override("font_color", Color.YELLOW)
	unit.add_child(state_label)

	var hp_label := Label.new()
	hp_label.name = "HPLabel"
	hp_label.position = Vector2(0.0, -30.0)
	hp_label.size = Vector2(UNIT_WIDTH, 16.0)
	hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hp_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hp_label.add_theme_font_size_override("font_size", 9)
	hp_label.add_theme_color_override("font_color", Color.WHITE)
	unit.add_child(hp_label)
	_hp_label = hp_label


func _build_hp_bar(unit: UnitInstance) -> void:
	var hp_bar_bg := ColorRect.new()
	hp_bar_bg.name = "HPBarBG"
	hp_bar_bg.position = Vector2(0.0, -14.0)
	hp_bar_bg.size = Vector2(UNIT_WIDTH, HP_BAR_HEIGHT)
	hp_bar_bg.color = Color(0.2, 0.2, 0.2, 0.8)
	unit.add_child(hp_bar_bg)

	var hp_bar_fill := ColorRect.new()
	hp_bar_fill.name = "HPBarFill"
	hp_bar_fill.position = Vector2(0.0, -14.0)
	hp_bar_fill.size = Vector2(UNIT_WIDTH, HP_BAR_HEIGHT)
	hp_bar_fill.color = Color(0.2, 0.8, 0.2)
	unit.add_child(hp_bar_fill)
	_hp_bar_fill = hp_bar_fill


func _build_unit_display(unit: UnitInstance) -> void:
	var background := ColorRect.new()
	background.size = Vector2(UNIT_WIDTH, UNIT_HEIGHT)
	background.color = Color(0.2, 0.2, 0.3, 1.0)
	unit.add_child(background)

	var image := TextureRect.new()
	image.name = "UnitImage"
	image.size = Vector2(UNIT_WIDTH, IMAGE_HEIGHT)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	unit.add_child(image)

	var label := Label.new()
	label.name = "UnitName"
	label.position = Vector2(0.0, IMAGE_HEIGHT)
	label.size = Vector2(UNIT_WIDTH, UNIT_HEIGHT - IMAGE_HEIGHT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 10)
	unit.add_child(label)


func _update_hp_bar(current_hp: int, max_hp: int) -> void:
	if _hp_bar_fill == null or max_hp <= 0:
		return
	var ratio: float = float(current_hp) / float(max_hp)
	ratio = clamp(ratio, 0.0, 1.0)
	_hp_bar_fill.size.x = UNIT_WIDTH * ratio
	if ratio > 0.5:
		_hp_bar_fill.color = Color(0.2, 0.8, 0.2)
	elif ratio > 0.25:
		_hp_bar_fill.color = Color(0.8, 0.8, 0.2)
	else:
		_hp_bar_fill.color = Color(0.8, 0.2, 0.2)


func _update_hp_label(current_hp: int, max_hp: int) -> void:
	if _hp_label:
		_hp_label.text = "%d/%d" % [current_hp, max_hp]


func _update_target_label(current_target: UnitInstance) -> void:
	var target_label: Label = get_node_or_null("TargetLabel")
	if target_label == null:
		return
	if current_target != null and is_instance_valid(current_target):
		target_label.text = "Target: %s" % current_target.definition.name
	else:
		target_label.text = "Target: None"
