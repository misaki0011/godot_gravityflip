class_name Player
extends CharacterBody2D

signal gravity_flipped(direction: int)
signal side_bounced
signal top_bottom_hit

var horizontal_speed := 280.0
var gravity_strength := 900.0
var horizontal_direction := 1
var gravity_direction := 1
var radius := 20.0
var accent := Color("9ad1d4")
var outline := Color("f6f1e9")
var arrow_fill := Color("f6f1e9")
var arrow_outline := Color("0d1b2a")
var _was_vertical_contact := false
var _vertical_contact_armed := false

func _ready() -> void:
	add_to_group("player")
	safe_margin = 0.08
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = radius
	collision.shape = shape
	add_child(collision)
	queue_redraw()

func _physics_process(delta: float) -> void:
	up_direction = Vector2.UP * -gravity_direction
	velocity.x = horizontal_speed * horizontal_direction
	velocity.y += gravity_strength * gravity_direction * delta
	move_and_slide()

	var current_vertical_contact := false
	var side_bounced_this_frame := false
	for index in get_slide_collision_count():
		var collision := get_slide_collision(index)
		if absf(collision.get_normal().x) > 0.7:
			var next_direction := int(sign(collision.get_normal().x))
			if next_direction != horizontal_direction and not side_bounced_this_frame:
				horizontal_direction = next_direction
				side_bounced.emit()
				side_bounced_this_frame = true
			else:
				horizontal_direction = next_direction
		if absf(collision.get_normal().y) > 0.7:
			current_vertical_contact = true

	if not current_vertical_contact:
		_vertical_contact_armed = true
	elif not _was_vertical_contact and _vertical_contact_armed:
		top_bottom_hit.emit()

	_was_vertical_contact = current_vertical_contact

func flip_gravity() -> void:
	gravity_direction *= -1
	gravity_flipped.emit(gravity_direction)
	queue_redraw()

func _draw() -> void:
	# Body — yellow
	draw_circle(Vector2.ZERO, radius, Color("ffb703"))
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32, outline, 3.5)

	# Eyes
	var eye_x := radius * 0.30
	var eye_y := radius * -0.15
	var eye_r := radius * 0.15
	draw_circle(Vector2(-eye_x, eye_y), eye_r, Color("1a1a2e"))
	draw_circle(Vector2(eye_x, eye_y), eye_r, Color("1a1a2e"))
	var shine_r := eye_r * 0.42
	draw_circle(Vector2(-eye_x + eye_r * 0.32, eye_y - eye_r * 0.32), shine_r, Color(1.0, 1.0, 1.0, 0.88))
	draw_circle(Vector2(eye_x + eye_r * 0.32, eye_y - eye_r * 0.32), shine_r, Color(1.0, 1.0, 1.0, 0.88))

	# Cheeks
	draw_circle(Vector2(-radius * 0.46, radius * 0.20), radius * 0.26, Color(1.0, 0.42, 0.42, 0.38))
	draw_circle(Vector2(radius * 0.46, radius * 0.20), radius * 0.26, Color(1.0, 0.42, 0.42, 0.38))

	# Gravity direction arrow — solid filled polygon with outline
	var dir := 1.0 if gravity_direction > 0 else -1.0
	var badge_center := Vector2(0.0, (radius + 16.0) * dir)

	# Classic arrow shape: narrow shaft + wide triangular head, pointing in dir
	var pts := PackedVector2Array([
		Vector2(-3.0, -10.0 * dir),  # shaft blunt-end left
		Vector2( 3.0, -10.0 * dir),  # shaft blunt-end right
		Vector2( 3.0,   0.0),        # shaft/head junction right
		Vector2( 8.5,   0.0),        # head wing right
		Vector2( 0.0,  12.0 * dir),  # tip
		Vector2(-8.5,   0.0),        # head wing left
		Vector2(-3.0,   0.0),        # shaft/head junction left
	])
	for i in pts.size():
		pts[i] += badge_center

	# Fill first, then outline on top
	draw_colored_polygon(pts, arrow_fill)
	var closed := pts.duplicate()
	closed.append(pts[0])
	draw_polyline(closed, arrow_outline, 2.5, true)
