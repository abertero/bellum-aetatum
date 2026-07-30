extends Node2D

const BASE_WIDTH: float = 80.0
const BASE_HEIGHT: float = 120.0
const CARD_BUTTON_WIDTH: float = 90.0
const CARD_BUTTON_HEIGHT: float = 130.0
const VIEWPORT_HEIGHT: float = 648.0
const ENEMY_SPAWN_INTERVAL: float = 3.0

var _stage_definition: StageDefinition
var _spawn_system: SpawnSystem
var _formation_system: FormationSystem
var _targeting_system: TargetingSystem
var _attack_system: AttackSystem
var _combat_system: CombatSystem
var _unit_container: Node2D
var _enemy_spawn_timer: float = 0.0
var _enemy_deck_index: int = 0


func _ready() -> void:
	_load_stage()
	_setup_battlefield()
	_setup_spawn_system()
	_setup_formation_system()
	_setup_targeting_system()
	_setup_attack_system()
	_setup_combat_system()
	_load_decks()
	_create_card_buttons()
	EventBus.battle_started.emit()


func _physics_process(delta: float) -> void:
	_update_enemy_spawn_timer(delta)


func _update_enemy_spawn_timer(delta: float) -> void:
	_enemy_spawn_timer += delta
	if _enemy_spawn_timer >= ENEMY_SPAWN_INTERVAL:
		_enemy_spawn_timer = 0.0
		_spawn_enemy_unit()


func _load_stage() -> void:
	var data: Variant = JsonLoader.load_json("res://data/stages/stage_001.json")
	if data != null:
		_stage_definition = StageDefinition.from_dictionary(data)
	else:
		push_error("BattleScene: using fallback stage data")
		_stage_definition = StageDefinition.create_fallback()


func _setup_battlefield() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.15, 0.2, 0.12)
	bg.size = Vector2(float(_stage_definition.battlefield_width), VIEWPORT_HEIGHT)
	add_child(bg)

	var player_base := ColorRect.new()
	player_base.color = Color(0.2, 0.4, 0.8)
	player_base.size = Vector2(BASE_WIDTH, BASE_HEIGHT)
	player_base.position = Vector2(40.0, (VIEWPORT_HEIGHT - BASE_HEIGHT) / 2.0)
	add_child(player_base)

	var enemy_base := ColorRect.new()
	enemy_base.color = Color(0.8, 0.2, 0.2)
	enemy_base.size = Vector2(BASE_WIDTH, BASE_HEIGHT)
	enemy_base.position = Vector2(
		float(_stage_definition.battlefield_width) - 40.0 - BASE_WIDTH,
		(VIEWPORT_HEIGHT - BASE_HEIGHT) / 2.0
	)
	add_child(enemy_base)

	_unit_container = Node2D.new()
	_unit_container.name = "UnitContainer"
	add_child(_unit_container)


func _setup_spawn_system() -> void:
	var unit_scene: PackedScene = load("res://scenes/unit.tscn")
	_spawn_system = SpawnSystem.new(unit_scene)


func _setup_formation_system() -> void:
	_formation_system = FormationSystem.new()
	var formation_spacing: float = _stage_definition.formation_spacing
	_formation_system.initialize(formation_spacing)
	add_child(_formation_system)


func _setup_targeting_system() -> void:
	_targeting_system = TargetingSystem.new()
	_targeting_system.initialize(_formation_system)
	add_child(_targeting_system)


func _setup_attack_system() -> void:
	_attack_system = AttackSystem.new()


func _setup_combat_system() -> void:
	_combat_system = CombatSystem.new()
	_combat_system.initialize(_formation_system, _attack_system)
	add_child(_combat_system)


func _load_decks() -> void:
	var player_deck: Array[UnitDefinition] = DeckSystem.load_player_deck("res://data/decks/player_deck.json")
	print("BattleScene: player deck loaded with %d cards" % player_deck.size())

	var enemy_deck: Array[UnitDefinition] = DeckSystem.load_enemy_deck("res://data/decks/enemy_deck.json")
	print("BattleScene: enemy deck loaded with %d cards" % enemy_deck.size())


func _create_card_buttons() -> void:
	var canvas_layer := CanvasLayer.new()
	add_child(canvas_layer)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	panel.offset_top = -CARD_BUTTON_HEIGHT - 10.0
	panel.offset_bottom = -10.0
	panel.offset_left = 10.0
	panel.offset_right = -10.0
	canvas_layer.add_child(panel)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 5)
	panel.add_child(hbox)

	var player_deck: Array[UnitDefinition] = DeckSystem.get_player_deck()
	for card_def: UnitDefinition in player_deck:
		var button: PanelContainer = _create_card_button(card_def)
		hbox.add_child(button)


func _create_card_button(card_def: UnitDefinition) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(CARD_BUTTON_WIDTH, CARD_BUTTON_HEIGHT)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	panel.add_child(vbox)
	vbox.add_child(_create_card_image(card_def))
	vbox.add_child(_create_label(card_def.name))
	vbox.add_child(_create_label("Cost: %d" % card_def.cost))
	var click_button := Button.new()
	click_button.flat = true
	click_button.set_anchors_preset(Control.PRESET_FULL_RECT)
	click_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	panel.add_child(click_button)
	click_button.pressed.connect(_on_card_pressed.bind(card_def))
	return panel


func _create_card_image(card_def: UnitDefinition) -> TextureRect:
	var image := TextureRect.new()
	image.custom_minimum_size = Vector2(64, 64)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var image_path: String = card_def.image
	if image_path != "" and ResourceLoader.exists(image_path):
		image.texture = load(image_path)
	else:
		image.texture = _create_placeholder(Vector2(64, 64), Color(0.3, 0.3, 0.5))
	return image


func _create_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 10)
	return label


func _on_card_pressed(card_def: UnitDefinition) -> void:
	var spawn_pos: Vector2 = _stage_definition.player_spawn_position
	var position := Vector2(spawn_pos.x, spawn_pos.y)
	position += Vector2(randf_range(-20.0, 20.0), randf_range(-20.0, 20.0))

	var target_pos: Vector2 = _stage_definition.enemy_spawn_position
	var target_position := Vector2(target_pos.x, target_pos.y)

	var unit: UnitInstance = _spawn_system.spawn_unit(card_def, position, target_position, _unit_container, "player")
	print("BattleScene: spawned %s" % card_def.name)


func _spawn_enemy_unit() -> void:
	var enemy_deck: Array[UnitDefinition] = DeckSystem.get_enemy_deck()
	if enemy_deck.is_empty():
		return

	var card_def: UnitDefinition = enemy_deck[_enemy_deck_index % enemy_deck.size()]
	_enemy_deck_index += 1

	var spawn_pos: Vector2 = _stage_definition.enemy_spawn_position
	var position := Vector2(spawn_pos.x, spawn_pos.y)
	position += Vector2(randf_range(-20.0, 20.0), randf_range(-20.0, 20.0))

	var target_pos: Vector2 = _stage_definition.player_spawn_position
	var target_position := Vector2(target_pos.x, target_pos.y)

	var unit: UnitInstance = _spawn_system.spawn_unit(card_def, position, target_position, _unit_container, "enemy")
	print("BattleScene: spawned enemy %s" % card_def.name)


func _create_placeholder(size: Vector2, color: Color) -> ImageTexture:
	var img := Image.create(int(size.x), int(size.y), false, Image.FORMAT_RGBA8)
	img.fill(color)
	return ImageTexture.create_from_image(img)
