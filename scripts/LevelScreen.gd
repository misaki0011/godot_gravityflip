class_name LevelScreen
extends Node2D

const BLOCK_TILE_SCRIPT := preload("res://scripts/BlockTile.gd")
const SPIKE_HAZARD_SCRIPT := preload("res://scripts/SpikeHazard.gd")
const GOAL_ZONE_SCRIPT := preload("res://scripts/GoalZone.gd")
const PLAYER_SCRIPT := preload("res://scripts/Player.gd")
const UI_FACTORY := preload("res://scripts/UiFactory.gd")
const LAB_BACKDROP := preload("res://scripts/LabBackdrop.gd")
const MUSIC_ON_ICON := preload("res://assets/music_on.svg")
const MUSIC_OFF_ICON := preload("res://assets/music_off.svg")
const STARTING_SCORE := 150
const REDUCTION_COST := 10

signal finished(success: bool, elapsed: float, reduction_count: int)
signal back_to_menu
signal music_toggled(enabled: bool)

const BASE_GRAVITY := 900.0

var level_data: Dictionary
var attempt_number := 1
var music_enabled := false

var _player: CharacterBody2D
var _elapsed := 0.0
var _is_finished := false
var _is_paused := false
var _score_label: Label
var _pause_overlay: ColorRect
var _music_button: Button
var _pause_button: Button
var _tile_size := 128.0
var _sz: Dictionary
var _reduction_count := 0
var _ignore_mouse_until_ms := 0
var _last_flip_ms := 0

func _init(data: Dictionary, attempt: int, music_on: bool) -> void:
	level_data = data
	attempt_number = attempt
	music_enabled = music_on

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	set_process_input(true)
	_build_world()
	_build_ui()

func _process(delta: float) -> void:
	if _is_finished or _is_paused:
		return
	_elapsed += delta

	# Fallback for browsers/devices where tap propagation differs.
	if Input.is_action_just_pressed("flip"):
		if _is_pointer_over_pause_button():
			return
		var now_ms := Time.get_ticks_msec()
		if now_ms - _last_flip_ms >= 120 and _player:
			_last_flip_ms = now_ms
			_player.flip_gravity()

func _unhandled_input(event: InputEvent) -> void:
	if _is_finished:
		return

	if event.is_action_pressed("pause"):
		_toggle_pause()
		get_viewport().set_input_as_handled()
		return

	if _is_paused:
		return

	if event.is_action_pressed("flip"):
		if _player:
			_player.flip_gravity()
			get_viewport().set_input_as_handled()

func _input(event: InputEvent) -> void:
	if _is_finished or _is_paused:
		return

	var now_ms := Time.get_ticks_msec()
	var tap_position := Vector2.ZERO
	var is_tap := false
	if event is InputEventScreenTouch and event.pressed:
		is_tap = true
		tap_position = event.position
		# Mobile/web often emits a synthetic mouse click after touch.
		_ignore_mouse_until_ms = now_ms + 350
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if now_ms < _ignore_mouse_until_ms:
			return
		is_tap = true
		tap_position = event.position

	if not is_tap:
		return

	if is_instance_valid(_pause_button):
		if _pause_button.get_global_rect().has_point(tap_position):
			return

	if now_ms - _last_flip_ms < 120:
		return

	if _player:
		_last_flip_ms = now_ms
		_player.flip_gravity()
		get_viewport().set_input_as_handled()

func _is_pointer_over_pause_button() -> bool:
	if not is_instance_valid(_pause_button):
		return false
	return _pause_button.get_global_rect().has_point(get_viewport().get_mouse_position())

func _build_world() -> void:
	var colors: Dictionary = level_data.colors
	_tile_size = float(level_data.get("tile_size", 128.0))

	var canvas := CanvasLayer.new()
	canvas.layer = -10
	add_child(canvas)
	var background_image_path := String(level_data.get("background_image", ""))
	if background_image_path != "":
		var texture := load(background_image_path)
		if texture is Texture2D:
			var texture_rect := TextureRect.new()
			texture_rect.texture = texture
			texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			texture_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			canvas.add_child(texture_rect)
		else:
			var backdrop: Control = LAB_BACKDROP.new()
			backdrop.set_palette(colors.background.darkened(0.35), colors.accent, colors.secondary)
			canvas.add_child(backdrop)
	else:
		var backdrop: Control = LAB_BACKDROP.new()
		backdrop.set_palette(colors.background.darkened(0.35), colors.accent, colors.secondary)
		canvas.add_child(backdrop)

	var world := Node2D.new()
	add_child(world)

	var terrain := Node2D.new()
	world.add_child(terrain)

	var row_count: int = level_data.rows.size()
	var column_count: int = String(level_data.rows[0]).length()
	var world_size := Vector2(column_count * _tile_size, row_count * _tile_size)

	var spawn_point := Vector2(_tile_size * 0.5, _tile_size * 0.5)
	for row_index in level_data.rows.size():
		var row: String = level_data.rows[row_index]
		for column in row.length():
			var tile_position := Vector2(column * _tile_size + _tile_size * 0.5, row_index * _tile_size + _tile_size * 0.5)
			match row.substr(column, 1):
				"#":
					var block: Variant = BLOCK_TILE_SCRIPT.new()
					block.tile_size = _tile_size
					var left_neighbor := row.substr(column - 1, 1) if column > 0 else ""
					var right_neighbor := row.substr(column + 1, 1) if column < row.length() - 1 else ""
					if left_neighbor in [".", "S", "G"]:
						block.direction_hint = "<<"
					elif right_neighbor in [".", "S", "G"]:
						block.direction_hint = ">>"
					block.position = tile_position
					terrain.add_child(block)
				"^":
					var spike: Variant = SPIKE_HAZARD_SCRIPT.new()
					spike.tile_size = _tile_size
					spike.position = tile_position
					spike.triggered.connect(func() -> void: _finish_level(false))
					terrain.add_child(spike)
				"G":
					var goal: Variant = GOAL_ZONE_SCRIPT.new()
					goal.tile_size = _tile_size
					goal.position = tile_position
					goal.reached.connect(func() -> void: _finish_level(true))
					world.add_child(goal)
				"S":
					spawn_point = tile_position

	var player_instance: CharacterBody2D = PLAYER_SCRIPT.new()
	_player = player_instance
	_player.position = spawn_point
	_player.gravity_strength = BASE_GRAVITY * float(level_data.gravity_multiplier)
	_player.accent = colors.secondary
	_player.side_bounced.connect(_register_reduction)
	_player.top_bottom_hit.connect(_register_reduction)
	world.add_child(_player)

	var camera := Camera2D.new()
	camera.enabled = true
	var viewport_size := get_viewport_rect().size
	var width_zoom := viewport_size.x / world_size.x
	var height_zoom := viewport_size.y / world_size.y
	var zoom_factor: float = min(width_zoom, height_zoom) * 0.92
	camera.zoom = Vector2.ONE / zoom_factor
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(world_size.x)
	camera.limit_bottom = int(world_size.y)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 6.0
	_player.add_child(camera)

func _build_ui() -> void:
	var vp := get_viewport_rect().size
	_sz = UI_FACTORY.layout_scale(vp)
	var layer := CanvasLayer.new()
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(layer)

	var hud := Control.new()
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(hud)

	var pause_btn_w := maxf(200.0 if _sz.is_phone else 170.0, _sz.btn_height * 3.2)
	var pause_margin_x := maxf(12.0, vp.x * 0.012)
	var pause_margin_y := maxf(12.0, vp.y * 0.015)
	var hud_gap := maxf(10.0, vp.x * 0.01)
	var score_max_width := maxf(180.0, vp.x - float(_sz.screen_margin) * 2.0 - pause_btn_w - pause_margin_x * 2.0 - hud_gap)
	var score_min_width := clampf(vp.x * 0.40, 180.0, 320.0)
	var top_row := HBoxContainer.new()
	top_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_row.anchor_left = 0.0
	top_row.anchor_right = 1.0
	top_row.anchor_top = 0.0
	top_row.anchor_bottom = 0.0
	top_row.offset_left = _sz.screen_margin
	top_row.offset_right = -_sz.screen_margin
	top_row.offset_top = pause_margin_y
	top_row.offset_bottom = pause_margin_y + clampf(vp.y * (0.20 if _sz.is_phone else 0.14), 130.0 if _sz.is_phone else 90.0, 190.0 if _sz.is_phone else 130.0)
	top_row.alignment = BoxContainer.ALIGNMENT_BEGIN
	top_row.add_theme_constant_override("separation", int(hud_gap))
	hud.add_child(top_row)

	var score_panel := UI_FACTORY.build_panel()
	score_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	score_panel.custom_minimum_size = Vector2(clampf(score_max_width, score_min_width, 820.0 if _sz.is_phone else 680.0), clampf(vp.y * (0.20 if _sz.is_phone else 0.14), 130.0 if _sz.is_phone else 90.0, 190.0 if _sz.is_phone else 130.0))
	score_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(score_panel)

	var score_box := VBoxContainer.new()
	score_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	score_box.add_theme_constant_override("separation", 8 if _sz.is_phone else 6)
	score_panel.add_child(UI_FACTORY.apply_margin(score_box, 18 if _sz.is_phone else 16))

	_score_label = UI_FACTORY.build_title_label("Score %d" % STARTING_SCORE, _sz.title_score)
	score_box.add_child(_score_label)
	_refresh_score_display()

	var score_hint := UI_FACTORY.build_body_label("Hit wall / top / bottom: -10", _sz.hint, true)
	score_box.add_child(score_hint)

	_pause_button = UI_FACTORY.build_button("Pause", "utility", 999)
	_pause_button.custom_minimum_size = Vector2(pause_btn_w, _sz.btn_height)
	_pause_button.add_theme_font_size_override("font_size", _sz.btn_font)
	_pause_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	_pause_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_pause_button.pressed.connect(_toggle_pause)
	top_row.add_child(_pause_button)

	_pause_overlay = ColorRect.new()
	_pause_overlay.color = Color(0.05, 0.08, 0.12, 0.86)
	_pause_overlay.visible = false
	_pause_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(_pause_overlay)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_pause_overlay.add_child(center)

	var margins := MarginContainer.new()
	margins.add_theme_constant_override("margin_left", _sz.screen_margin)
	margins.add_theme_constant_override("margin_top", _sz.screen_margin)
	margins.add_theme_constant_override("margin_right", _sz.screen_margin)
	margins.add_theme_constant_override("margin_bottom", _sz.screen_margin)
	center.add_child(margins)

	var panel := UI_FACTORY.build_panel()
	panel.custom_minimum_size = Vector2(clampf(vp.x - _sz.screen_margin * 2.0, 340.0, 720.0 if _sz.is_phone else 560.0), 0.0)
	margins.add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _sz.panel_gap)
	panel.add_child(UI_FACTORY.apply_margin(box, _sz.panel_pad))

	var title_row := HBoxContainer.new()
	title_row.alignment = BoxContainer.ALIGNMENT_CENTER
	title_row.add_theme_constant_override("separation", maxi(10, int(_sz.music_icon * 0.24)))
	box.add_child(title_row)
	title_row.add_child(UI_FACTORY.build_title_label("Paused", _sz.title_large))

	_music_button = UI_FACTORY.build_button("", "utility")
	_music_button.custom_minimum_size = Vector2(_sz.music_icon, _sz.music_icon)
	_music_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	_music_button.pressed.connect(_on_music_pressed)
	title_row.add_child(_music_button)
	_refresh_music_button()

	var restart_button := UI_FACTORY.build_button("Restart", "primary", 999)
	_style_pause_button(restart_button)
	restart_button.pressed.connect(func() -> void:
		_toggle_pause(false)
		finished.emit(false, 0.0, 0)
	)
	box.add_child(restart_button)

	var resume_button := UI_FACTORY.build_button("Resume", "utility", 999)
	_style_pause_button(resume_button)
	resume_button.pressed.connect(_toggle_pause)
	box.add_child(resume_button)

	var back_button := UI_FACTORY.build_button("Back To Menu", "exit", 999)
	_style_pause_button(back_button)
	back_button.pressed.connect(func() -> void:
		_toggle_pause(false)
		back_to_menu.emit()
	)
	box.add_child(back_button)

func _style_pause_button(button: Button) -> void:
	button.custom_minimum_size = Vector2(0.0, _sz.btn_height)
	button.add_theme_font_size_override("font_size", _sz.btn_font)

func _register_reduction() -> void:
	_reduction_count += 1
	_refresh_score_display()

func _refresh_score_display() -> void:
	if is_instance_valid(_score_label):
		_score_label.text = "Score %d" % maxi(0, STARTING_SCORE - _reduction_count * REDUCTION_COST)

func _toggle_pause(force_toggle := true) -> void:
	if _is_finished:
		return
	if force_toggle:
		_is_paused = not _is_paused
	else:
		_is_paused = false
	get_tree().paused = _is_paused
	_pause_overlay.visible = _is_paused

func _on_music_pressed() -> void:
	music_enabled = not music_enabled
	_refresh_music_button()
	music_toggled.emit(music_enabled)

func _refresh_music_button() -> void:
	_music_button.text = ""
	_music_button.icon = MUSIC_ON_ICON if music_enabled else MUSIC_OFF_ICON
	_music_button.expand_icon = true
	_music_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_music_button.tooltip_text = "Music %s" % ("ON" if music_enabled else "OFF")

func _finish_level(success: bool) -> void:
	if _is_finished:
		return
	_is_finished = true
	get_tree().paused = false
	finished.emit(success, _elapsed, _reduction_count)
