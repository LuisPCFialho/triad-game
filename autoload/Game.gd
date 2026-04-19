extends Node

const SAVE_PATH := "user://savegame.json"
const MAX_HIGH_SCORES := 10
const STREAK_MILESTONE := 5  # every 5 kills in streak => +1 Prism

var current_score: int = 0
var enemies_killed: int = 0
var run_time_seconds: float = 0.0
var run_active: bool = false

var kill_streak: int = 0
var highest_streak: int = 0

var high_scores: Array = []
var settings := {
	"master_volume": 0.8,
	"sfx_volume": 0.8,
	"music_volume": 0.6,
	"fullscreen": false,
}


func _ready() -> void:
	_load()
	Signals.player_damaged.connect(_on_player_damaged)
	Signals.player_died.connect(_on_player_died)


func reset_run() -> void:
	current_score = 0
	enemies_killed = 0
	run_time_seconds = 0.0
	kill_streak = 0
	highest_streak = 0
	run_active = true
	CurrencyManager.reset_run_earnings()


func _process(delta: float) -> void:
	if run_active:
		run_time_seconds += delta


func add_score(points: int) -> void:
	current_score += points
	Signals.score_changed.emit(current_score)


func register_kill(at_position: Vector2, _kind: String) -> void:
	kill_streak += 1
	highest_streak = max(highest_streak, kill_streak)
	if kill_streak > 0 and kill_streak % STREAK_MILESTONE == 0:
		CurrencyManager.add("prisms", 1, at_position)


func _on_player_damaged(_amount: int, _hp_remaining: int) -> void:
	kill_streak = 0


func _on_player_died() -> void:
	run_active = false
	CurrencyManager.end_run_banking()
	record_run()
	Signals.game_over.emit()


func record_run() -> void:
	var entry := {
		"score": current_score,
		"time": run_time_seconds,
		"kills": enemies_killed,
		"streak": highest_streak,
		"date": Time.get_datetime_string_from_system(),
	}
	high_scores.append(entry)
	high_scores.sort_custom(func(a, b): return a.score > b.score)
	if high_scores.size() > MAX_HIGH_SCORES:
		high_scores = high_scores.slice(0, MAX_HIGH_SCORES)
	_save()


func _save() -> void:
	var data := {"high_scores": high_scores, "settings": settings}
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
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	high_scores = parsed.get("high_scores", [])
	var loaded_settings: Dictionary = parsed.get("settings", {})
	for k in loaded_settings.keys():
		settings[k] = loaded_settings[k]
