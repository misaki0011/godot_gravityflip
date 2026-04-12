class_name ResultScreen
extends Control

const UI_FACTORY := preload("res://scripts/UiFactory.gd")
const RESULT_BACKDROP := preload("res://scripts/ResultBackdrop.gd")
const LEVEL_CATALOG_SCRIPT := preload("res://scripts/LevelCatalog.gd")
const CLEAR_BACKGROUND_TEXTURE := preload("res://assets/background_clear.png")
const TRYAGAIN_BACKGROUND_TEXTURE := preload("res://assets/background_tryagain.png")
const MUSIC_ON_ICON := preload("res://assets/music_on.svg")
const MUSIC_OFF_ICON := preload("res://assets/music_off.svg")

signal next_pressed
signal restart_pressed
signal back_pressed
signal music_toggled(enabled: bool)

var _state
var _music_enabled := false
var _toggle_button: Button
var _sz: Dictionary

func _init(state, music_enabled: bool = false) -> void:
	_state = state
	_music_enabled = music_enabled

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var vp := get_viewport_rect().size
	_sz = UI_FACTORY.layout_scale(vp.y)
	var result: Dictionary = _state.last_result
	var success := bool(result.success)

	var chosen_texture: Texture2D = CLEAR_BACKGROUND_TEXTURE if success else TRYAGAIN_BACKGROUND_TEXTURE
	if chosen_texture:
		var background := TextureRect.new()
		background.texture = chosen_texture
		background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(background)
	else:
		var backdrop: Control = RESULT_BACKDROP.new()
		backdrop.set_result_state(success)
		add_child(backdrop)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var margins := MarginContainer.new()
	margins.add_theme_constant_override("margin_left", 24)
	margins.add_theme_constant_override("margin_top", 24)
	margins.add_theme_constant_override("margin_right", 24)
	margins.add_theme_constant_override("margin_bottom", 24)
	center.add_child(margins)

	var panel := UI_FACTORY.build_panel()
	panel.custom_minimum_size = Vector2(minf(560.0, vp.x - 48.0), 0.0)
	margins.add_child(panel)

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 18)
	panel.add_child(UI_FACTORY.apply_margin(box, 28))

	var title_row := HBoxContainer.new()
	title_row.alignment = BoxContainer.ALIGNMENT_CENTER
	title_row.add_theme_constant_override("separation", 12)
	box.add_child(title_row)

	_toggle_button = UI_FACTORY.build_button("", "utility")
	_toggle_button.custom_minimum_size = Vector2(_sz.music_icon, _sz.music_icon)
	_toggle_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	_toggle_button.pressed.connect(_on_music_pressed)

	# Title row
	if success:
		title_row.add_child(UI_FACTORY.build_title_label("%s  Clear!" % result.title, _sz.title_large))
	else:
		title_row.add_child(UI_FACTORY.build_title_label("Try Again", _sz.title_large))
	title_row.add_child(_toggle_button)
	_refresh_music_button()

	# Score breakdown (success only — score is only saved on goal reached)
	if success:
		box.add_child(UI_FACTORY.build_title_label("Score  %d" % int(result.score), _sz.title_score))
		box.add_child(UI_FACTORY.build_body_label("Hit %d  (× -10)" % int(result.reductions), _sz.body, true))

	# Buttons
	var next_button := UI_FACTORY.build_button("Next", "primary", 999)
	_style_action_button(next_button)
	next_button.disabled = not success or int(result.level_index) >= LEVEL_CATALOG_SCRIPT.count() - 1
	next_button.pressed.connect(func() -> void: next_pressed.emit())
	box.add_child(next_button)

	var restart_button := UI_FACTORY.build_button("Restart", "utility", 999)
	_style_action_button(restart_button)
	restart_button.pressed.connect(func() -> void: restart_pressed.emit())
	box.add_child(restart_button)

	var back_button := UI_FACTORY.build_button("Back To Menu", "exit", 999)
	_style_action_button(back_button)
	back_button.pressed.connect(func() -> void: back_pressed.emit())
	box.add_child(back_button)

func _style_action_button(button: Button) -> void:
	button.custom_minimum_size = Vector2(0.0, _sz.btn_height)
	button.add_theme_font_size_override("font_size", _sz.btn_font)

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
