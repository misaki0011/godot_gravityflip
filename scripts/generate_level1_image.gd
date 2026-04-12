extends SceneTree

const TILE_SIZE := 128
const LAYOUT := [
	"....................",
	"....................",
	"....................",
	"..........####......",
	"....................",
	"S..................G",
	"########....########",
	".......^....^.......",
	"####################",
]

func _init() -> void:
	var wall: Image = Image.load_from_file("res://assets/tile_bluewall_128x128.png")
	var spike: Image = Image.load_from_file("res://assets/tile_spike_128x128.png")

	var output := Image.create_empty(LAYOUT[0].length() * TILE_SIZE, LAYOUT.size() * TILE_SIZE, false, Image.FORMAT_RGBA8)
	output.fill(Color(0, 0, 0, 0))

	for row in LAYOUT.size():
		var row_text: String = LAYOUT[row]
		for column in row_text.length():
			var cell := row_text.substr(column, 1)
			var position := Vector2i(column * TILE_SIZE, row * TILE_SIZE)
			if cell == "#":
				output.blit_rect(wall, Rect2i(Vector2i.ZERO, wall.get_size()), position)
			elif cell == "^":
				output.blend_rect(spike, Rect2i(Vector2i.ZERO, spike.get_size()), position)

	var save_path := "res://assets/level1_layout.png"
	var result := output.save_png(save_path)
	if result != OK:
		push_error("Failed to save level image: %s" % error_string(result))
	quit(result)
