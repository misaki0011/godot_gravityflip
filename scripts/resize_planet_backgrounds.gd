extends SceneTree

const TARGET_SIZE: Vector2i = Vector2i(1920, 1080)
const FILES: Array[String] = [
	"earth",
	"moon",
	"mars",
	"jupiter",
]

func _init() -> void:
	for planet in FILES:
		var source_path: String = "res://assets/background_%s.png" % planet
		var output_path: String = "res://assets/background_%s_1920x1080.png" % planet
		var image: Image = Image.load_from_file(source_path)
		if image.is_empty():
			push_error("Failed to load %s" % source_path)
			quit(ERR_CANT_OPEN)
			return

		var resized: Image = _resize_cover(image, TARGET_SIZE)
		var result: int = resized.save_png(output_path)
		if result != OK:
			push_error("Failed to save %s: %s" % [output_path, error_string(result)])
			quit(result)
			return

	quit()

func _resize_cover(source: Image, target_size: Vector2i) -> Image:
	var source_size := Vector2(source.get_width(), source.get_height())
	var target: Vector2 = Vector2(target_size.x, target_size.y)
	var scale: float = max(target.x / source_size.x, target.y / source_size.y)
	var scaled_size: Vector2i = Vector2i(
		int(ceil(source_size.x * scale)),
		int(ceil(source_size.y * scale))
	)

	var working: Image = source.duplicate()
	working.resize(scaled_size.x, scaled_size.y, Image.INTERPOLATE_LANCZOS)

	var crop_origin: Vector2i = Vector2i(
		int((scaled_size.x - target_size.x) / 2),
		int((scaled_size.y - target_size.y) / 2)
	)

	var output: Image = Image.create_empty(target_size.x, target_size.y, false, working.get_format())
	output.blit_rect(working, Rect2i(crop_origin, target_size), Vector2i.ZERO)
	return output
