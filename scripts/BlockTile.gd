class_name BlockTile
extends StaticBody2D

const WALL_TEXTURE := preload("res://assets/tile_bluewall_128x128.png")

var tile_size := 128.0
var direction_hint := ""

func _ready() -> void:
	var sprite := Sprite2D.new()
	sprite.texture = WALL_TEXTURE
	add_child(sprite)

	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(tile_size, tile_size)
	collision.shape = shape
	add_child(collision)

	if direction_hint != "":
		var label := Label.new()
		label.text = direction_hint
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.size = Vector2(tile_size, tile_size)
		label.position = Vector2(-tile_size * 0.5, -tile_size * 0.5)
		label.add_theme_font_size_override("font_size", int(tile_size * 0.42))
		label.add_theme_color_override("font_color", Color("f6f1e9"))
		label.add_theme_color_override("font_outline_color", Color("0d1b2a"))
		label.add_theme_constant_override("outline_size", 6)
		add_child(label)
