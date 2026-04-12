extends SceneTree

const SOURCE_PATH := "res://assets/logo.png"
const OUTPUT_PATH := "res://assets/logo_cropped.png"

func _init() -> void:
	var image: Image = Image.load_from_file(SOURCE_PATH)
	if image.is_empty():
		push_error("Failed to load %s" % SOURCE_PATH)
		quit(ERR_CANT_OPEN)
		return

	var bounds: Rect2i = _find_nontransparent_bounds(image)
	if bounds.size.x <= 0 or bounds.size.y <= 0:
		push_error("No visible pixels found in %s" % SOURCE_PATH)
		quit(ERR_INVALID_DATA)
		return

	var cropped: Image = Image.create_empty(bounds.size.x, bounds.size.y, false, image.get_format())
	cropped.blit_rect(image, bounds, Vector2i.ZERO)

	var result: int = cropped.save_png(ProjectSettings.globalize_path(OUTPUT_PATH))
	if result != OK:
		push_error("Failed to save %s: %s" % [OUTPUT_PATH, error_string(result)])
		quit(result)
		return

	quit()

func _find_nontransparent_bounds(image: Image) -> Rect2i:
	var min_x: int = image.get_width()
	var min_y: int = image.get_height()
	var max_x: int = -1
	var max_y: int = -1

	for y in image.get_height():
		for x in image.get_width():
			var pixel: Color = image.get_pixel(x, y)
			if pixel.a > 0.01:
				min_x = mini(min_x, x)
				min_y = mini(min_y, y)
				max_x = maxi(max_x, x)
				max_y = maxi(max_y, y)

	if max_x < min_x or max_y < min_y:
		return Rect2i()

	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)
