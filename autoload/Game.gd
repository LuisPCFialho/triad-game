extends Node

const SAVE_PATH := "user://savegame.json"
const MAX_HIGH_SCORES := 10

var current_score: int = 0
var current_wave: int = 0
var enemies_killed: int = 0
var run_time_seconds: float = 0.0
var active_upgrades: Array[String] = []

var high_scores: Array = []
var settings := {
	"master_volume": 0.8,
	"sfx_volume": 0.8,
	"music_volume": 0.6,
	"fullscreen": false,
}


func _ready() -> void:
	_load()


func reset_run() -> void:
	current_score = 0
	current_wave = 0
	enemies_killed = 0
	run_time_seconds = 0.0
	active_upgrades.clear()


func add_score(points: int) -> void:
	current_score += points
	Signals.score_changed.emit(current_score)


func record_run() -> void:
	var entry := {
		"score": current_score,
		"wave": current_wave,
		"kills": enemies_killed,
		"time": run_time_seconds,
		"date": Time.get_datetime_string_from_system(),
	}
	high_scores.append(entry)
	high_scores.sort_custom(func(a, b): return a.score > b.score)
	if high_scores.size() > MAX_HIGH_SCORES:
		high_scores = high_scores.slice(0, MAX_HIGH_SCORES)
	_save()


func _save() -> void:
	var data := {
		"high_scores": high_scores,
		"settings": settings,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open save file for writing")
		return
	file.store_string(JSON.stringify(data, "\t"))


func _load() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var text := file.get_as_text()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	high_scores = parsed.get("high_scores", [])
	var loaded_settings: Dictionary = parsed.get("settings", {})
	for k in loaded_settings.keys():
		settings[k] = loaded_settings[k]
