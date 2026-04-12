class_name SpikeHazard
extends Area2D

signal triggered

const SPIKE_TEXTURE := preload("res://assets/tile_spike_128x128.png")

var tile_size := 128.0

func _ready() -> void:
	monitorable = true
	monitoring = true

	var sprite := Sprite2D.new()
	sprite.texture = SPIKE_TEXTURE
	add_child(sprite)

	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(tile_size * 0.92, tile_size * 0.92)
	collision.shape = shape
	add_child(collision)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		triggered.emit()
