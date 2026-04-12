class_name ResultBackdrop
extends Control

var _is_success := false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func set_result_state(success: bool) -> void:
	_is_success = success
	queue_redraw()

func _draw() -> void:
	var rect := get_rect()
	if _is_success:
		_draw_sunny_clear(rect)
	else:
		_draw_rainy_try_again(rect)

func _draw_sunny_clear(rect: Rect2) -> void:
	# Sunny clear scene: bright sky, sun shine, and blooming flowers.
	draw_rect(rect, Color("87c8ff"), true)
	draw_rect(Rect2(Vector2(0.0, rect.size.y * 0.74), Vector2(rect.size.x, rect.size.y * 0.26)), Color("64b35a"), true)

	var sun_center := Vector2(rect.size.x * 0.15, rect.size.y * 0.18)
	var sun_radius := rect.size.y * 0.09
	for i in 12:
		var angle := TAU * float(i) / 12.0
		var inner := sun_center + Vector2(cos(angle), sin(angle)) * (sun_radius + 8.0)
		var outer := sun_center + Vector2(cos(angle), sin(angle)) * (sun_radius + 36.0)
		draw_line(inner, outer, Color("ffe066"), 4.0)
	draw_circle(sun_center, sun_radius, Color("ffd43b"))

	_draw_flower(rect, rect.size.x * 0.18, rect.size.y * 0.80, Color("ff8fab"))
	_draw_flower(rect, rect.size.x * 0.32, rect.size.y * 0.83, Color("ffa94d"))
	_draw_flower(rect, rect.size.x * 0.48, rect.size.y * 0.79, Color("b197fc"))
	_draw_flower(rect, rect.size.x * 0.65, rect.size.y * 0.82, Color("74c0fc"))
	_draw_flower(rect, rect.size.x * 0.82, rect.size.y * 0.80, Color("f783ac"))

func _draw_rainy_try_again(rect: Rect2) -> void:
	# Rainy try-again scene: cool sky, dark clouds, rain streaks, and wet ground.
	draw_rect(rect, Color("355070"), true)
	draw_rect(Rect2(Vector2(0.0, rect.size.y * 0.74), Vector2(rect.size.x, rect.size.y * 0.26)), Color("2f3e46"), true)

	draw_circle(Vector2(rect.size.x * 0.22, rect.size.y * 0.18), rect.size.y * 0.08, Color("6c7a89"))
	draw_circle(Vector2(rect.size.x * 0.29, rect.size.y * 0.16), rect.size.y * 0.07, Color("7d8597"))
	draw_circle(Vector2(rect.size.x * 0.36, rect.size.y * 0.18), rect.size.y * 0.08, Color("6c7a89"))

	draw_circle(Vector2(rect.size.x * 0.62, rect.size.y * 0.20), rect.size.y * 0.07, Color("6c7a89"))
	draw_circle(Vector2(rect.size.x * 0.68, rect.size.y * 0.18), rect.size.y * 0.06, Color("7d8597"))
	draw_circle(Vector2(rect.size.x * 0.74, rect.size.y * 0.20), rect.size.y * 0.07, Color("6c7a89"))

	for i in 18:
		var x := rect.size.x * (0.04 + float(i) * 0.055)
		draw_line(Vector2(x, rect.size.y * 0.28), Vector2(x - 16.0, rect.size.y * 0.66), Color("a5d8ff"), 2.2)

	# A couple of simple puddles.
	draw_circle(Vector2(rect.size.x * 0.24, rect.size.y * 0.87), rect.size.y * 0.028, Color(0.66, 0.86, 1.0, 0.45))
	draw_circle(Vector2(rect.size.x * 0.78, rect.size.y * 0.89), rect.size.y * 0.033, Color(0.66, 0.86, 1.0, 0.45))

func _draw_flower(rect: Rect2, x: float, y: float, petal_color: Color) -> void:
	var stem_top := y - rect.size.y * 0.05
	draw_line(Vector2(x, y), Vector2(x, stem_top), Color("2f7d32"), 3.0)
	draw_circle(Vector2(x, stem_top), rect.size.y * 0.012, Color("ffd43b"))
	var pr := rect.size.y * 0.012
	draw_circle(Vector2(x - pr * 1.6, stem_top), pr, petal_color)
	draw_circle(Vector2(x + pr * 1.6, stem_top), pr, petal_color)
	draw_circle(Vector2(x, stem_top - pr * 1.6), pr, petal_color)
	draw_circle(Vector2(x, stem_top + pr * 1.6), pr, petal_color)
