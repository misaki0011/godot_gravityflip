extends Node

const GAME_STATE_SCRIPT := preload("res://scripts/GameState.gd")
const MUSIC_CONTROLLER_SCRIPT := preload("res://scripts/MusicController.gd")
const TITLE_SCREEN_SCRIPT := preload("res://scripts/TitleScreen.gd")
const MENU_SCREEN_SCRIPT := preload("res://scripts/MenuScreen.gd")
const LEVEL_SCREEN_SCRIPT := preload("res://scripts/LevelScreen.gd")
const RESULT_SCREEN_SCRIPT := preload("res://scripts/ResultScreen.gd")
const LEVEL_CATALOG_SCRIPT := preload("res://scripts/LevelCatalog.gd")

var _state: RefCounted = GAME_STATE_SCRIPT.new()
var _music: Node
var _current_screen: Node

func _ready() -> void:
	_setup_input_map()
	_music = MUSIC_CONTROLLER_SCRIPT.new()
	add_child(_music)
	_music.set_music_enabled(_state.music_enabled)
	_show_title()

func _setup_input_map() -> void:
	if not InputMap.has_action("flip"):
		InputMap.add_action("flip")
		var key := InputEventKey.new()
		key.physical_keycode = KEY_SPACE
		InputMap.action_add_event("flip", key)
	if not InputMap.has_action("pause"):
		InputMap.add_action("pause")
		var key_pause := InputEventKey.new()
		key_pause.physical_keycode = KEY_ESCAPE
		InputMap.action_add_event("pause", key_pause)

func _set_screen(screen: Node) -> void:
	if _current_screen:
		_current_screen.queue_free()
	_current_screen = screen
	add_child(screen)

func _show_title() -> void:
	var screen: Node = TITLE_SCREEN_SCRIPT.new(_state.music_enabled)
	screen.start_pressed.connect(_show_menu)
	screen.quit_pressed.connect(func() -> void: get_tree().quit())
	screen.music_toggled.connect(_set_music_enabled)
	_set_screen(screen)

func _show_menu() -> void:
	var screen: Node = MENU_SCREEN_SCRIPT.new(_state, _state.music_enabled)
	screen.back_pressed.connect(_show_title)
	screen.level_selected.connect(_start_level)
	screen.music_toggled.connect(_set_music_enabled)
	_set_screen(screen)

func _start_level(level_index: int) -> void:
	_state.current_level_index = level_index
	var level: Dictionary = LEVEL_CATALOG_SCRIPT.get_level(level_index)
	var attempt: int = _state.register_attempt(level.id)
	var screen: Node = LEVEL_SCREEN_SCRIPT.new(level, attempt, _state.music_enabled)
	screen.finished.connect(func(success: bool, elapsed: float, reduction_count: int) -> void:
		if not success and elapsed <= 0.0 and reduction_count <= 0:
			_start_level(_state.current_level_index)
			return
		_state.record_result(_state.current_level_index, success, elapsed, reduction_count)
		_show_result()
	)
	screen.back_to_menu.connect(_show_menu)
	screen.music_toggled.connect(_set_music_enabled)
	_set_screen(screen)

func _show_result() -> void:
	var screen: Node = RESULT_SCREEN_SCRIPT.new(_state, _state.music_enabled)
	screen.next_pressed.connect(func() -> void: _start_level(mini(_state.current_level_index + 1, LEVEL_CATALOG_SCRIPT.count() - 1)))
	screen.restart_pressed.connect(func() -> void: _start_level(_state.current_level_index))
	screen.back_pressed.connect(_show_menu)
	screen.music_toggled.connect(_set_music_enabled)
	_set_screen(screen)

func _set_music_enabled(enabled: bool) -> void:
	_state.music_enabled = enabled
	_music.set_music_enabled(enabled)
