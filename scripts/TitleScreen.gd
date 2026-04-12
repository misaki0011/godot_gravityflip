class_name TitleScreen
extends Control

const UI_FACTORY := preload("res://scripts/UiFactory.gd")
const TITLE_BACKGROUND_TEXTURE := preload("res://assets/background_1920x1080.png")
const TITLE_LOGO_TEXTURE := preload("res://assets/logo_cropped_tight.png")
const TAP_SPACE_TEXTURE := preload("res://assets/tap_space.png")
const MUSIC_ON_ICON := preload("res://assets/music_on.svg")
const MUSIC_OFF_ICON := preload("res://assets/music_off.svg")

signal start_pressed
signal quit_pressed
signal music_toggled(enabled: bool)

var _music_enabled := false
var _overlay: ColorRect
var _toggle_button: Button
var _layout_host: Control
var _sz: Dictionary

func _init(music_enabled: bool = false) -> void:
	_music_enabled = music_enabled

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_add_background()
	_sz = UI_FACTORY.layout_scale(get_viewport_rect().size.y)
	_layout_host = Control.new()
	_layout_host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_layout_host)
	_rebuild_layout()

	_build_overlay()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_instance_valid(_layout_host):
		_rebuild_layout()

func _rebuild_layout() -> void:
	for child in _layout_host.get_children():
		child.queue_free()

	var viewport_size := get_viewport_rect().size
	_sz = UI_FACTORY.layout_scale(viewport_size.y)
	var use_landscape := viewport_size.x >= viewport_size.y * 1.05

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_layout_host.add_child(center)

	var margins := MarginContainer.new()
	margins.add_theme_constant_override("margin_left", 24)
	margins.add_theme_constant_override("margin_top", 24)
	margins.add_theme_constant_override("margin_right", 24)
	margins.add_theme_constant_override("margin_bottom", 24)
	center.add_child(margins)

	if use_landscape:
		_build_landscape_layout(margins, viewport_size)
	else:
		_build_portrait_layout(margins, viewport_size)

func _build_landscape_layout(parent: Control, viewport_size: Vector2) -> void:
	var content_width := clampf(viewport_size.x - 96.0, 960.0, 1320.0)
	var content_height := clampf(viewport_size.y - 96.0, 540.0, 720.0)

	var root := HBoxContainer.new()
	root.custom_minimum_size = Vector2(content_width, content_height)
	root.add_theme_constant_override("separation", 28)
	parent.add_child(root)

	var hero := CenterContainer.new()
	hero.custom_minimum_size = Vector2(content_width * 0.62, content_height)
	hero.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(hero)
	var logo_size := Vector2(content_width * 0.60, content_height * 0.72)
	hero.add_child(_build_logo_wrap(logo_size))
	var actions_width := logo_size.x / 3.0

	var actions_panel := UI_FACTORY.build_panel()
	actions_panel.custom_minimum_size = Vector2(actions_width, minf(266.0, content_height * 0.5))
	actions_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	root.add_child(actions_panel)
	actions_panel.add_child(UI_FACTORY.apply_margin(_build_actions_box(false), 14))

func _build_portrait_layout(parent: Control, viewport_size: Vector2) -> void:
	var content_width := clampf(viewport_size.x - 72.0, 320.0, 980.0)
	var hero_width := clampf(viewport_size.x - 28.0, content_width, 1100.0)
	var available_height := viewport_size.y - 48.0
	var hero_height := available_height * (2.0 / 3.0)
	var buttons_height := available_height - hero_height
	var logo_size := Vector2(hero_width, hero_height)
	var actions_width := hero_width * 0.8

	var root := VBoxContainer.new()
	root.custom_minimum_size = Vector2(hero_width, available_height)
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_theme_constant_override("separation", 0)
	parent.add_child(root)

	var hero := CenterContainer.new()
	hero.custom_minimum_size = Vector2(hero_width, hero_height)
	root.add_child(hero)
	hero.add_child(_build_logo_wrap(logo_size))

	var btn_holder := Control.new()
	btn_holder.custom_minimum_size = Vector2(hero_width, buttons_height)
	root.add_child(btn_holder)
	var actions_panel := UI_FACTORY.build_panel()
	actions_panel.anchor_left = 0.5
	actions_panel.anchor_right = 0.5
	actions_panel.anchor_top = 0.0
	actions_panel.anchor_bottom = 1.0
	actions_panel.offset_left = -actions_width * 0.5
	actions_panel.offset_right = actions_width * 0.5
	actions_panel.offset_top = 0.0
	actions_panel.offset_bottom = 0.0
	btn_holder.add_child(actions_panel)
	var btn_height := buttons_height / 4.5
	var btn_font := maxi(14, int(btn_height * 0.38))
	var btn_icon := btn_height * 0.55
	actions_panel.add_child(UI_FACTORY.apply_margin(_build_actions_box(true, btn_height, btn_font, btn_icon), 12))

func _build_logo_wrap(size: Vector2) -> Control:
	var logo_wrap := Control.new()
	logo_wrap.custom_minimum_size = size

	if TITLE_LOGO_TEXTURE is Texture2D:
		var shadow := TextureRect.new()
		shadow.texture = TITLE_LOGO_TEXTURE
		shadow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		shadow.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		shadow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		shadow.scale = Vector2(1.06, 1.06)
		shadow.position = Vector2(-size.x * 0.03, -size.y * 0.025)
		shadow.modulate = Color(0.02, 0.04, 0.08, 0.42)
		logo_wrap.add_child(shadow)

		var logo := TextureRect.new()
		logo.texture = TITLE_LOGO_TEXTURE
		logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		logo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		logo_wrap.add_child(logo)

	return logo_wrap

func _build_actions_box(compact: bool = false, btn_height: float = 0.0, btn_font: int = 0, btn_icon: float = 0.0) -> VBoxContainer:
	var actions := VBoxContainer.new()
	actions.add_theme_constant_override("separation", 8 if compact else 10)

	var music_row := HBoxContainer.new()
	music_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	music_row.alignment = BoxContainer.ALIGNMENT_END
	actions.add_child(music_row)

	_toggle_button = _build_title_button("", "utility")
	var _icon_sz: float = btn_icon if btn_icon > 0.0 else float(_sz.music_icon)
	_toggle_button.custom_minimum_size = Vector2(_icon_sz, _icon_sz)
	_toggle_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	_toggle_button.pressed.connect(_on_music_pressed)
	music_row.add_child(_toggle_button)
	_refresh_music_button()

	var start_button := _build_title_button("Start")
	if compact:
		_style_compact_title_button(start_button, btn_height if btn_height > 0.0 else 34.0, btn_font if btn_font > 0 else 14)
	start_button.pressed.connect(func() -> void: start_pressed.emit())
	actions.add_child(start_button)

	var how_to_play_button := _build_title_button("How To Play", "utility")
	if compact:
		_style_compact_title_button(how_to_play_button, btn_height if btn_height > 0.0 else 34.0, btn_font if btn_font > 0 else 14)
	how_to_play_button.pressed.connect(_show_overlay)
	actions.add_child(how_to_play_button)

	var quit_button := _build_title_button("Quit", "exit")
	if compact:
		_style_compact_title_button(quit_button, btn_height if btn_height > 0.0 else 34.0, btn_font if btn_font > 0 else 14)
	quit_button.pressed.connect(func() -> void: quit_pressed.emit())
	actions.add_child(quit_button)

	return actions

func _build_title_button(text: String, role: String = "primary") -> Button:
	var button := UI_FACTORY.build_button(text, role, 999)
	button.custom_minimum_size = Vector2(0.0, _sz.btn_height)
	button.add_theme_font_size_override("font_size", _sz.btn_font)
	return button

func _style_compact_title_button(button: Button, btn_height: float = 34.0, btn_font: int = 14) -> void:
	button.custom_minimum_size = Vector2(0.0, btn_height)
	button.add_theme_font_size_override("font_size", btn_font)

func _build_overlay() -> void:
	_overlay = ColorRect.new()
	_overlay.color = Color(0.05, 0.08, 0.12, 0.85)
	_overlay.visible = false
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_overlay)

	var vp := get_viewport_rect().size

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.add_child(center)

	var margins := MarginContainer.new()
	margins.add_theme_constant_override("margin_left", 24)
	margins.add_theme_constant_override("margin_top", 24)
	margins.add_theme_constant_override("margin_right", 24)
	margins.add_theme_constant_override("margin_bottom", 24)
	center.add_child(margins)

	var panel := UI_FACTORY.build_panel()
	panel.custom_minimum_size = Vector2(minf(680.0, vp.x - 48.0), 0.0)
	margins.add_child(panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", maxi(12, int(vp.y * 0.018)))
	panel.add_child(UI_FACTORY.apply_margin(content, 28))

	content.add_child(UI_FACTORY.build_title_label("How To Play", _sz.title_large))
	content.add_child(UI_FACTORY.build_body_label("Gravity Flip Lab is a simple action game where momentum keeps going even when gravity changes.", _sz.body, true))
	content.add_child(UI_FACTORY.build_body_label("Tap screen or press Space to flip gravity.", _sz.hint, true))

	if TAP_SPACE_TEXTURE is Texture2D:
		var input_image := TextureRect.new()
		input_image.texture = TAP_SPACE_TEXTURE
		input_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		input_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		input_image.custom_minimum_size = Vector2(0.0, clampf(vp.y * 0.22, 120.0, 200.0))
		input_image.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		content.add_child(input_image)

	var close_button := UI_FACTORY.build_button("Back", "exit", 999)
	close_button.custom_minimum_size = Vector2(0.0, _sz.btn_height)
	close_button.add_theme_font_size_override("font_size", _sz.btn_font)
	close_button.pressed.connect(func() -> void: _overlay.visible = false)
	content.add_child(close_button)

func _show_overlay() -> void:
	_overlay.visible = true

func _on_music_pressed() -> void:
	_music_enabled = not _music_enabled
	_refresh_music_button()
	music_toggled.emit(_music_enabled)

func _refresh_music_button() -> void:
	_toggle_button.text = ""
	_toggle_button.icon = MUSIC_ON_ICON if _music_enabled else MUSIC_OFF_ICON
	_toggle_button.expand_icon = true
	_toggle_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toggle_button.tooltip_text = "Music %s" % ("ON" if _music_enabled else "OFF")

func _add_background() -> void:
	if TITLE_BACKGROUND_TEXTURE is Texture2D:
		var background := TextureRect.new()
		background.texture = TITLE_BACKGROUND_TEXTURE
		background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(background)
