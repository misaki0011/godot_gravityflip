class_name GoalZone
extends Area2D

signal reached

var tile_size := 64.0
var fill_color := Color("ffb703")
var outline_color := Color("f6f1e9")

func _ready() -> void:
	monitorable = true
	monitoring = true
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(tile_size * 0.84, tile_size * 0.84)
	collision.shape = shape
	add_child(collision)
	body_entered.connect(_on_body_entered)
	queue_redraw()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		reached.emit()

func _draw() -> void:
	var rect := Rect2(Vector2(-tile_size * 0.42, -tile_size * 0.42), Vector2.ONE * tile_size * 0.84)
	draw_rect(rect, fill_color, true)
	draw_rect(rect, outline_color, false, 4.0)
	draw_circle(Vector2.ZERO, tile_size * 0.16, outline_color)
