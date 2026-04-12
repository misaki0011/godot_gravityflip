class_name GameState
extends RefCounted

const LEVEL_CATALOG_SCRIPT := preload("res://scripts/LevelCatalog.gd")
const STARTING_SCORE := 150
const REDUCTION_COST := 10

var music_enabled := false
var current_level_index := 0
var best_scores: Dictionary = {}
var completion: Dictionary = {}
var attempts: Dictionary = {}
var last_result := {
	"success": false,
	"level_index": 0,
	"time": 0.0,
	"reductions": 0,
	"score": 0,
	"attempt": 1,
	"title": ""
}

func register_attempt(level_id: String) -> int:
	var count := int(attempts.get(level_id, 0)) + 1
	attempts[level_id] = count
	return count

func record_result(level_index: int, success: bool, elapsed: float, reduction_count: int) -> void:
	var level = LEVEL_CATALOG_SCRIPT.get_level(level_index)
	var level_id := String(level.id)
	var attempt := int(attempts.get(level_id, 1))
	var score := score_from_reductions(reduction_count)
	if success:
		completion[level_id] = true
		var previous_best := int(best_scores.get(level_id, -1))
		if score > previous_best:
			best_scores[level_id] = score
	last_result = {
		"success": success,
		"level_index": level_index,
		"time": elapsed,
		"reductions": reduction_count,
		"score": score,
		"attempt": attempt,
		"title": LEVEL_CATALOG_SCRIPT.display_name(level_index),
		"planet": String(level.planet)
	}

func is_cleared(level_id: String) -> bool:
	return bool(completion.get(level_id, false))

func is_unlocked(level_index: int) -> bool:
	if level_index <= 0:
		return true
	var previous_level = LEVEL_CATALOG_SCRIPT.get_level(level_index - 1)
	return is_cleared(String(previous_level.id))

func best_score_for(level_id: String) -> int:
	return int(best_scores.get(level_id, 0))

func attempt_count_for(level_id: String) -> int:
	return int(attempts.get(level_id, 0))

func score_for(level_id: String) -> int:
	if not is_cleared(level_id):
		return 0
	return best_score_for(level_id)

func score_from_reductions(reduction_count: int) -> int:
	return maxi(0, STARTING_SCORE - reduction_count * REDUCTION_COST)

func total_score() -> int:
	var total: int = 0
	for level_entry in LEVEL_CATALOG_SCRIPT.all():
		var level: Dictionary = level_entry
		total += score_for(String(level.id))
	return total
