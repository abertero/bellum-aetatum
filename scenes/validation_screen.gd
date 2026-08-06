extends Control

var _report: ContentReport = null
var _scroll: ScrollContainer = null
var _content_label: Label = null


func _ready() -> void:
	_build_ui()


func display_report(report: ContentReport) -> void:
	_report = report
	_refresh_display()


func _build_ui() -> void:
	name = "ValidationScreen"
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color(0.1, 0.1, 0.15, 0.95)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	var title := Label.new()
	title.text = "Content Validation Report"
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(title)

	var close_btn := Button.new()
	close_btn.text = "Close & Continue"
	close_btn.pressed.connect(_on_close_pressed)
	vbox.add_child(close_btn)

	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(_scroll)

	_content_label = Label.new()
	_content_label.add_theme_font_size_override("font_size", 12)
	_content_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_scroll.add_child(_content_label)


func _refresh_display() -> void:
	if _report == null or _content_label == null:
		return
	_content_label.text = _report.get_summary()
	if _report.diagnostics.get_error_count() > 0:
		_content_label.text += "\n" + _report.get_error_summary()
	if _report.diagnostics.get_warning_count() > 0:
		_content_label.text += "\n" + _report.get_warning_summary()


func _on_close_pressed() -> void:
	queue_free()
