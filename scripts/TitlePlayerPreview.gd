class_name TitlePlayerPreview
extends Node2D

const RADIUS := 28.0
const BALL_COLOR := Color("ffb703")
const OUTLINE_COLOR := Color("f6f1e9")
const ARROW_FILL := Color("f6f1e9")
const ARROW_OUTLINE := Color("0d1b2a")
const FLIP_INTERVAL := 2.2

var gravity_direction := 1

var _t := 0.0
var _flip_timer := 0.0
var _bob_offset := 0.0

func _process(delta: float) -> void:
	_t += delta
	_flip_timer += delta
	if _flip_timer >= FLIP_INTERVAL:
		_flip_timer = 0.0
		gravity_direction *= -1
	_bob_offset = sin(_t * 2.0) * 12.0
	queue_redraw()

func _draw() -> void:
	var center := Vector2(0.0, _bob_offset)
	draw_circle(center, RADIUS, BALL_COLOR)
	draw_arc(center, RADIUS, 0.0, TAU, 32, OUTLINE_COLOR, 4.0)

	var direction := 1.0 if gravity_direction > 0 else -1.0
	var badge_center := center + Vector2(0.0, (RADIUS + 12.0) * direction)
	var shaft_start := badge_center + Vector2(0.0, -8.0 * direction)
	var shaft_end := badge_center + Vector2(0.0, 8.0 * direction)
	var arrow_tip := badge_center + Vector2(0.0, 15.0 * direction)
	var left_tip := arrow_tip + Vector2(-7.0, -7.0 * direction)
	var right_tip := arrow_tip + Vector2(7.0, -7.0 * direction)

	draw_line(shaft_start, shaft_end, ARROW_OUTLINE, 7.0)
	draw_line(arrow_tip, left_tip, ARROW_OUTLINE, 7.0)
	draw_line(arrow_tip, right_tip, ARROW_OUTLINE, 7.0)
	draw_line(shaft_start, shaft_end, ARROW_FILL, 3.5)
	draw_line(arrow_tip, left_tip, ARROW_FILL, 3.5)
	draw_line(arrow_tip, right_tip, ARROW_FILL, 3.5)
