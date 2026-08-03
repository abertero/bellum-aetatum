class_name ProjectileInstance
extends Node2D

var id: String = ""
var direction: Vector2 = Vector2.ZERO
var speed: float = 0.0
var owner_unit: UnitInstance = null
var target_unit: UnitInstance = null
var remaining_distance: float = 0.0
var projectile_type: String = ""
var metadata: Dictionary = {}
var _visual: Sprite2D = null
var _debug_label: Label = null
var debug_mode: bool = false


func initialize(
	p_id: String,
	p_position: Vector2,
	p_direction: Vector2,
	p_speed: float,
	p_owner: UnitInstance,
	p_target: UnitInstance,
	p_max_range: float,
	p_projectile_type: String,
	p_image: String,
	p_metadata: Dictionary = {}
) -> void:
	id = p_id
	position = p_position
	direction = p_direction.normalized()
	speed = p_speed
	owner_unit = p_owner
	target_unit = p_target
	remaining_distance = p_max_range
	projectile_type = p_projectile_type
	metadata = p_metadata.duplicate()
	_setup_visual(p_image)
	_setup_debug_label()


func _setup_visual(image_path: String) -> void:
	_visual = Sprite2D.new()
	_visual.name = "ProjectileSprite"
	add_child(_visual)
	
	if image_path != "" and ResourceLoader.exists(image_path):
		_visual.texture = load(image_path)
	else:
		_visual.texture = _create_placeholder_texture()
	
	_visual.rotation = direction.angle()


func _setup_debug_label() -> void:
	_debug_label = Label.new()
	_debug_label.name = "DebugLabel"
	_debug_label.position = Vector2(0, -20)
	_debug_label.add_theme_font_size_override("font_size", 8)
	_debug_label.add_theme_color_override("font_color", Color.YELLOW)
	_debug_label.visible = debug_mode
	add_child(_debug_label)


func _create_placeholder_texture() -> ImageTexture:
	var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.8, 0.2, 0.2, 0.9))
	return ImageTexture.create_from_image(img)


func update_movement(delta: float) -> void:
	var movement: Vector2 = direction * speed * delta
	position += movement
	remaining_distance -= movement.length()
	_update_debug_label()


func _update_debug_label() -> void:
	if not debug_mode or _debug_label == null:
		return
	var target_name: String = "None"
	if target_unit != null and is_instance_valid(target_unit):
		target_name = target_unit.definition.name
	_debug_label.text = "ID: %s\nSpd: %.0f\nDist: %.0f\nTarget: %s" % [
		id, speed, remaining_distance, target_name
	]


func has_reached_target() -> bool:
	if target_unit == null or not is_instance_valid(target_unit):
		return true
	var distance_to_target: float = position.distance_to(target_unit.position)
	return distance_to_target < 8.0 or remaining_distance <= 0.0


func is_expired() -> bool:
	return remaining_distance <= 0.0


func get_metadata(key: String, default: Variant = null) -> Variant:
	return metadata.get(key, default)
