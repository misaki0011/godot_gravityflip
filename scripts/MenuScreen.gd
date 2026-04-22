class_name MenuScreen
extends Control

const UI_FACTORY := preload("res://scripts/UiFactory.gd")
const LEVEL_CATALOG_SCRIPT := preload("res://scripts/LevelCatalog.gd")
const MUSIC_ON_ICON := "res://assets/music_on.svg"
const MUSIC_OFF_ICON := "res://assets/music_off.svg"
const COMING_SOON_COUNT := 6
const MENU_BACKGROUND_TEXTURE := preload("res://assets/background_1920x1080.png")

signal back_pressed
signal level_selected(level_index: int)
signal music_toggled(enabled: bool)

const SCORE_COLUMN_WIDTH := 88.0

var _state
var _music_enabled := false
var _toggle_button: Button
var _sz: Dictionary
var _vp: Vector2

func _init(state, music_enabled: bool = false) -> void:
	_state = state
	_music_enabled = music_enabled

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_add_background()
	var vp := get_viewport_rect().size
	_vp = vp
	_sz = UI_FACTORY.layout_scale(vp)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var margins := MarginContainer.new()
	var outer_vertical_margin := maxf(float(_sz.screen_margin), vp.y * (0.11 if _sz.is_phone else 0.08))
	margins.add_theme_constant_override("margin_left", _sz.screen_margin)
	margins.add_theme_constant_override("margin_top", int(outer_vertical_margin))
	margins.add_theme_constant_override("margin_right", _sz.screen_margin)
	margins.add_theme_constant_override("margin_bottom", int(outer_vertical_margin))
	center.add_child(margins)

	var panel := UI_FACTORY.build_panel()
	panel.custom_minimum_size = Vector2(
		clampf(vp.x - _sz.screen_margin * 2.0, 340.0, 920.0 if _sz.is_phone else 820.0),
		clampf(vp.y * (0.72 if _sz.is_phone else 0.68), vp.y * 0.56, vp.y - outer_vertical_margin * 2.0)
	)
	margins.add_child(panel)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", _sz.panel_gap)
	panel.add_child(UI_FACTORY.apply_margin(root, _sz.panel_pad))

	var header := HBoxContainer.new()
	header.alignment = BoxContainer.ALIGNMENT_CENTER
	header.add_theme_constant_override("separation", 18 if _sz.is_phone else 16)
	root.add_child(header)

	header.add_child(UI_FACTORY.build_title_label("Level Selection", _sz.title_large))

	_toggle_button = UI_FACTORY.build_button("", "utility")
	_toggle_button.custom_minimum_size = Vector2(_sz.music_icon, _sz.music_icon)
	_toggle_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	_toggle_button.pressed.connect(_on_music_pressed)
	header.add_child(_toggle_button)
	_refresh_music_button()

	root.add_child(_build_total_score_row())

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0.0, clampf(vp.y * (0.42 if _sz.is_phone else 0.34), 240.0 if _sz.is_phone else 180.0, 420.0 if _sz.is_phone else 320.0))
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll)

	var scroll_margin := MarginContainer.new()
	scroll_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_margin.add_theme_constant_override("margin_right", maxi(8, int(_sz.screen_margin * 0.75)))
	scroll.add_child(scroll_margin)

	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 14 if _sz.is_phone else 12)
	scroll_margin.add_child(list)

	for index in LEVEL_CATALOG_SCRIPT.count():
		list.add_child(_build_level_row(index))

	for offset in COMING_SOON_COUNT:
		list.add_child(_build_coming_soon_row(LEVEL_CATALOG_SCRIPT.count() + offset))

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0.0, clampf(_vp.y * 0.012, 6.0, 16.0))
	root.add_child(spacer)

	var back_button := UI_FACTORY.build_button("Back To Title", "exit", 999)
	_style_menu_button(back_button)
	back_button.pressed.connect(func() -> void: back_pressed.emit())
	root.add_child(back_button)

func _style_menu_button(button: Button) -> void:
	button.custom_minimum_size = Vector2(0.0, _sz.btn_height)
	button.add_theme_font_size_override("font_size", _sz.btn_font)

func _build_total_score_row() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", maxi(10, int(_sz.body * 0.45)))
	row.alignment = BoxContainer.ALIGNMENT_END

	var label := UI_FACTORY.build_body_label("Total Score", _sz.body, false)
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.custom_minimum_size = Vector2(190.0 if _sz.is_phone else 160.0, 0.0)
	row.add_child(label)

	var value := UI_FACTORY.build_body_label("%d" % _state.total_score(), _sz.body, false)
	value.custom_minimum_size = Vector2(maxf(SCORE_COLUMN_WIDTH, _sz.body * 4.4), 0.0)
	value.autowrap_mode = TextServer.AUTOWRAP_OFF
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(value)
	return row

func _build_level_row(index: int) -> Control:
	var level: Dictionary = LEVEL_CATALOG_SCRIPT.get_level(index)
	var unlocked: bool = _state.is_unlocked(index)
	var score: int = _state.score_for(String(level.id))
	var score_text := "%d" % score if unlocked else "-"

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", maxi(10, int(_sz.body * 0.45)))

	var button := UI_FACTORY.build_button(LEVEL_CATALOG_SCRIPT.display_name(index), "primary", 999)
	_style_menu_button(button)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.tooltip_text = level.description
	button.disabled = not unlocked
	if unlocked:
		button.pressed.connect(func() -> void: level_selected.emit(index))
	row.add_child(button)

	var value := UI_FACTORY.build_body_label(score_text, _sz.body, false)
	value.custom_minimum_size = Vector2(maxf(SCORE_COLUMN_WIDTH, _sz.body * 4.4), 0.0)
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(value)

	return row

func _build_coming_soon_row(index: int) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", maxi(10, int(_sz.body * 0.45)))

	var button := UI_FACTORY.build_button("Coming Soon", "utility", 999)
	_style_menu_button(button)
	button.disabled = true
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.tooltip_text = "Future level slot"
	row.add_child(button)

	var value := UI_FACTORY.build_body_label("-", _sz.body, false)
	value.custom_minimum_size = Vector2(maxf(SCORE_COLUMN_WIDTH, _sz.body * 4.4), 0.0)
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(value)

	return row

func _on_music_pressed() -> void:
	_music_enabled = not _music_enabled
	_refresh_music_button()
	music_toggled.emit(_music_enabled)

func _refresh_music_button() -> void:
	_toggle_button.text = ""
	var icon = load(MUSIC_ON_ICON if _music_enabled else MUSIC_OFF_ICON)
	if icon is Texture2D:
		_toggle_button.icon = icon
		_toggle_button.expand_icon = true
		_toggle_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toggle_button.tooltip_text = "Music %s" % ("ON" if _music_enabled else "OFF")

func _add_background() -> void:
	if MENU_BACKGROUND_TEXTURE is Texture2D:
		var background := TextureRect.new()
		background.texture = MENU_BACKGROUND_TEXTURE
		background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(background)
