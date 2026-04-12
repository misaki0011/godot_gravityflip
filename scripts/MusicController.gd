class_name MusicController
extends Node

const MUSIC_STREAM := preload("res://assets/gamemusic.mp3")

var _player: AudioStreamPlayer
var _enabled := false
var _web_unlock_logged := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_player = AudioStreamPlayer.new()
	_player.bus = "Master"
	var stream := MUSIC_STREAM
	if stream:
		stream.loop = true
	_player.stream = stream
	_player.volume_db = -16.0
	add_child(_player)
	if _enabled:
		_player.play()
	set_process_input(true)
	if _enabled:
		_try_resume_web_audio_context()

func set_music_enabled(enabled: bool) -> void:
	_enabled = enabled
	if not _player:
		return

	if enabled:
		_try_resume_web_audio_context()
		if _player.playing:
			_player.stream_paused = false
		else:
			_player.play()
	else:
		if _player.playing:
			_player.stream_paused = true

func _input(event: InputEvent) -> void:
	if not _enabled:
		return
	if event is InputEventMouseButton and event.pressed:
		_try_resume_web_audio_context()
	elif event is InputEventScreenTouch and event.pressed:
		_try_resume_web_audio_context()
	elif event is InputEventKey and event.pressed:
		_try_resume_web_audio_context()

func _try_resume_web_audio_context() -> void:
	if not OS.has_feature("web"):
		return
	if not ClassDB.class_exists("JavaScriptBridge"):
		return
	var result: Variant = JavaScriptBridge.eval("""
		(function () {
			try {
				if (typeof window.GodotAudio === 'undefined' || !GodotAudio.ctx) {
					return 'missing';
				}
				if (GodotAudio.ctx.state !== 'running') {
					GodotAudio.ctx.resume();
				}
				return GodotAudio.ctx.state;
			} catch (e) {
				return 'error:' + e;
			}
		}());
	""", true)
	if result is String and result.begins_with("error:"):
		if not _web_unlock_logged:
			_web_unlock_logged = true
			push_warning("Web audio unlock failed: %s" % result)
	elif result == "running":
		_web_unlock_logged = true
