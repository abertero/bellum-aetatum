class_name Unit
extends Node2D

const UNIT_WIDTH: float = 64.0
const UNIT_HEIGHT: float = 80.0
const IMAGE_HEIGHT: float = 64.0

var _card_data: Dictionary


func _ready() -> void:
	_build_visual()


func initialize(card_data: Dictionary) -> void:
	_card_data = card_data
	_apply_data()


func _build_visual() -> void:
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


func _create_placeholder(size: Vector2, color: Color) -> ImageTexture:
	var img := Image.create(int(size.x), int(size.y), false, Image.FORMAT_RGBA8)
	img.fill(color)
	return ImageTexture.create_from_image(img)
