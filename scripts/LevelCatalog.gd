class_name LevelCatalog
extends RefCounted

const LEVELS := [
	{
		"id": "earth_level_1",
		"display_name": "Lv01-Earth",
		"title": "Level 1",
		"planet": "Earth",
		"gravity_multiplier": 1.0,
		"description": "A beginner-friendly Earth stage built from the provided dirt and spike tiles.",
		"tile_size": 128.0,
		"background_image": "res://assets/background_earth_1920x1080.png",
		"colors": {
			"background": Color("dff3ff"),
			"secondary": Color("9ad1d4"),
			"accent": Color("ffb703"),
			"danger": Color("e76f51"),
			"terrain": Color("7f5539")
		},
		"rows": [
			"######################",
			"#....................#",
			"#....................#",
			"#....................#",
			"#..........####......#",
			"#....................#",
			"#S..................G#",
			"#########....#########",
			"#.......^....^.......#",
			"######################"
		]
	},
	{
		"id": "moon",
		"display_name": "Lv02-Moon",
		"title": "Moon Drift",
		"planet": "Moon",
		"gravity_multiplier": 0.16,
		"description": "Very low gravity means every flip carries momentum for much longer.",
		"background_image": "res://assets/background_moon_1920x1080.png",
		"colors": {
			"background": Color("f2f0ff"),
			"secondary": Color("cdb4db"),
			"accent": Color("ffd166"),
			"danger": Color("ef476f"),
			"terrain": Color("5f6f94")
		},
		"rows": [
			"####################",
			"#..................#",
			"#..S...............#",
			"#..............^...#",
			"#.....####.........#",
			"#..................#",
			"#..........####....#",
			"#..................#",
			"#...............G..#",
			"#.......^..........#",
			"####################"
		]
	},
	{
		"id": "mars",
		"display_name": "Lv03-Mars",
		"title": "Mars Switchbacks",
		"planet": "Mars",
		"gravity_multiplier": 0.38,
		"description": "Medium gravity introduces longer planning and tighter wall reversals.",
		"background_image": "res://assets/background_mars_1920x1080.png",
		"colors": {
			"background": Color("fff0e6"),
			"secondary": Color("f4a261"),
			"accent": Color("e9c46a"),
			"danger": Color("d62828"),
			"terrain": Color("9c6644")
		},
		"rows": [
			"####################",
			"#..................#",
			"#..S.....^.........#",
			"#.............###..#",
			"#..................#",
			"#....####..........#",
			"#..................#",
			"#..........^.......#",
			"#..............G...#",
			"#..................#",
			"####################"
		]
	},
	{
		"id": "jupiter",
		"display_name": "Lv04-Jupiter",
		"title": "Jupiter Pressure",
		"planet": "Jupiter",
		"gravity_multiplier": 2.5,
		"description": "Strong gravity punishes late flips and rewards fast reactions.",
		"background_image": "res://assets/background_jupiter_1920x1080.png",
		"colors": {
			"background": Color("fff4ea"),
			"secondary": Color("d4a373"),
			"accent": Color("ffb703"),
			"danger": Color("bc4749"),
			"terrain": Color("774936")
		},
		"rows": [
			"####################",
			"#..................#",
			"#..S...............#",
			"#.........^........#",
			"#......####........#",
			"#..................#",
			"#............####..#",
			"#.......^..........#",
			"#...............G..#",
			"#..................#",
			"####################"
		]
	}
]

static func count() -> int:
	return LEVELS.size()

static func all() -> Array:
	return LEVELS.duplicate(true)

static func get_level(index: int) -> Dictionary:
	return LEVELS[clampi(index, 0, LEVELS.size() - 1)].duplicate(true)

static func display_name(index: int) -> String:
	var level := get_level(index)
	return String(level.get("display_name", "Level%02d" % [index + 1]))
