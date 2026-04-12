class_name UiFactory
extends RefCounted

const COLOR_TEXT := Color("f6f1e9")
const COLOR_DARK := Color("0d1b2a")
const COLOR_PANEL := Color("17324d")
const COLOR_PANEL_SOFT := Color("23415f")
const COLOR_PRIMARY := Color("ffb703")
const COLOR_UTILITY := Color("9ad1d4")
const COLOR_EXIT := Color("e76f51")
const COLOR_DISABLED := Color("6c7a89")

static func build_button(text: String, role: String = "primary", corner_radius: int = 18) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0.0, 54.0)
	button.focus_mode = Control.FOCUS_NONE
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 24)
	button.add_theme_color_override("font_color", COLOR_DARK)
	button.add_theme_color_override("font_pressed_color", COLOR_DARK)
	button.add_theme_color_override("font_hover_color", COLOR_DARK)
	button.add_theme_color_override("font_disabled_color", COLOR_TEXT)
	button.add_theme_stylebox_override("normal", _button_style(_color_for_role(role), 0, corner_radius))
	button.add_theme_stylebox_override("hover", _button_style(_color_for_role(role).lightened(0.08), 2, corner_radius))
	button.add_theme_stylebox_override("pressed", _button_style(_color_for_role(role).darkened(0.12), 0, corner_radius))
	button.add_theme_stylebox_override("disabled", _button_style(COLOR_DISABLED, 0, corner_radius))
	return button

static func build_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style())
	return panel

static func build_title_label(text: String, size: int = 54) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", COLOR_TEXT)
	return label

static func build_body_label(text: String, size: int = 20, centered: bool = true) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if centered else HORIZONTAL_ALIGNMENT_LEFT
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", COLOR_TEXT)
	return label

static func build_value_chip(text: String) -> Button:
	var chip := Button.new()
	chip.text = text
	chip.disabled = true
	chip.focus_mode = Control.FOCUS_NONE
	chip.add_theme_font_size_override("font_size", 18)
	chip.add_theme_color_override("font_color", COLOR_TEXT)
	chip.add_theme_color_override("font_disabled_color", COLOR_TEXT)
	chip.add_theme_stylebox_override("disabled", _chip_style())
	return chip

static func apply_margin(container: Control, margin: int = 24) -> MarginContainer:
	var wrapper := MarginContainer.new()
	wrapper.add_theme_constant_override("margin_left", margin)
	wrapper.add_theme_constant_override("margin_top", margin)
	wrapper.add_theme_constant_override("margin_right", margin)
	wrapper.add_theme_constant_override("margin_bottom", margin)
	wrapper.add_child(container)
	return wrapper

static func format_time(value: float) -> String:
	if value <= 0.0:
		return "--"
	return "%.2fs" % value

static func touch_button_height(viewport_height: float, ratio: float = 0.075, min_height: float = 56.0, max_height: float = 84.0) -> float:
	return clampf(viewport_height * ratio, min_height, max_height)

static func touch_button_font_size(button_height: float, ratio: float = 0.42, min_size: int = 20) -> int:
	return maxi(min_size, int(round(button_height * ratio)))

static func touch_music_icon_size(viewport_height: float, ratio: float = 0.05, min_size: float = 34.0, max_size: float = 46.0) -> float:
	return clampf(viewport_height * ratio, min_size, max_size)

static func touch_label_size(viewport_height: float, ratio: float = 0.045, min_size: int = 20, max_size: int = 52) -> int:
	return clampi(int(round(viewport_height * ratio)), min_size, max_size)

# Returns all viewport-scaled sizes for a screen in one call.
# Usage:  var _sz := UI_FACTORY.layout_scale(get_viewport_rect().size.y)
# Keys:   btn_height, btn_font, music_icon,
#         title_large, title_score, body, hint
static func layout_scale(viewport_height: float) -> Dictionary:
	var btn_h := clampf(viewport_height * 0.08, 58.0, 84.0)
	return {
		"btn_height":   btn_h,
		"btn_font":     maxi(22, int(round(btn_h * 0.42))),
		"music_icon":   clampf(viewport_height * 0.05, 36.0, 50.0),
		"title_large":  clampi(int(round(viewport_height * 0.058)), 32, 48),
		"title_score":  clampi(int(round(viewport_height * 0.050)), 28, 42),
		"body":         clampi(int(round(viewport_height * 0.038)), 20, 28),
		"hint":         clampi(int(round(viewport_height * 0.030)), 16, 22),
	}

static func _color_for_role(role: String) -> Color:
	match role:
		"utility":
			return COLOR_UTILITY
		"exit":
			return COLOR_EXIT
		_:
			return COLOR_PRIMARY

static func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_PANEL
	style.border_width_left = 4
	style.border_width_top = 4
	style.border_width_right = 4
	style.border_width_bottom = 4
	style.border_color = COLOR_TEXT
	style.corner_radius_top_left = 24
	style.corner_radius_top_right = 24
	style.corner_radius_bottom_right = 24
	style.corner_radius_bottom_left = 24
	return style

static func _button_style(fill: Color, shadow_offset: int, corner_radius: int = 18) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = COLOR_DARK
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.corner_radius_top_left = corner_radius
	style.corner_radius_top_right = corner_radius
	style.corner_radius_bottom_left = corner_radius
	style.corner_radius_bottom_right = corner_radius
	style.expand_margin_bottom = shadow_offset
	return style

static func _chip_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_PANEL_SOFT
	style.border_color = COLOR_TEXT
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_left = 18
	style.corner_radius_bottom_right = 18
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style
