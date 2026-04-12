class_name LabBackdrop
extends Control

var palette := {
	"base": Color("10233a"),
	"accent": Color("ffb703"),
	"secondary": Color("9ad1d4")
}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func set_palette(base: Color, accent: Color, secondary: Color) -> void:
	palette["base"] = base
	palette["accent"] = accent
	palette["secondary"] = secondary
	queue_redraw()

func _draw() -> void:
	var rect := get_rect()
	draw_rect(rect, palette["base"], true)
	draw_circle(Vector2(rect.size.x * 0.83, rect.size.y * 0.23), 110.0, palette["secondary"])
	draw_circle(Vector2(rect.size.x * 0.18, rect.size.y * 0.82), 150.0, palette["accent"].darkened(0.15))
	draw_rect(Rect2(Vector2(0.0, rect.size.y * 0.72), Vector2(rect.size.x, rect.size.y * 0.28)), palette["base"].lightened(0.08), true)
	for index in 10:
		var start := Vector2(index * 160.0 - 80.0, rect.size.y * 0.68)
		var end := start + Vector2(140.0, -40.0)
		draw_line(start, end, palette["secondary"].darkened(0.2), 3.0)
