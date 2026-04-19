extends Node

signal skill_unlocked(skill_id: String)

const SAVE_PATH := "user://skills.json"
const SKILL_DATA_PATH := "res://data/skill_tree.json"

var skill_data: Dictionary = {}
var unlocked: Dictionary = {}


func _ready() -> void:
	_load_data()
	_load_progress()


func _load_data() -> void:
	var file := FileAccess.open(SKILL_DATA_PATH, FileAccess.READ)
	if file == null:
		push_error("Cannot load skill tree data at %s" % SKILL_DATA_PATH)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Skill tree data is invalid JSON")
		return
	skill_data = parsed


func get_tree_skills(tree_name: String) -> Array:
	if not skill_data.has("trees"):
		return []
	var trees: Dictionary = skill_data.get("trees", {})
	return trees.get(tree_name, [])


func has(skill_id: String) -> bool:
	return unlocked.get(skill_id, false)


func can_unlock(skill_id: String) -> bool:
	var skill := _find_skill(skill_id)
	if skill.is_empty():
		return false
	if has(skill_id):
		return false
	var prereqs: Array = skill.get("prereqs", [])
	for pre in prereqs:
		if not has(pre):
			return false
	return CurrencyManager.can_afford(skill.get("cost", {}))


func try_unlock(skill_id: String) -> bool:
	if not can_unlock(skill_id):
		return false
	var skill := _find_skill(skill_id)
	if not CurrencyManager.spend(skill.get("cost", {})):
		return false
	unlocked[skill_id] = true
	_save_progress()
	skill_unlocked.emit(skill_id)
	return true


func get_modifier(key: String, default: float = 0.0) -> float:
	var total: float = default
	for skill_id in unlocked.keys():
		if not unlocked[skill_id]:
			continue
		var skill := _find_skill(skill_id)
		var effects: Dictionary = skill.get("effects", {})
		if effects.has(key):
			total += float(effects[key])
	return total


func has_flag(flag: String) -> bool:
	for skill_id in unlocked.keys():
		if not unlocked[skill_id]:
			continue
		var skill := _find_skill(skill_id)
		var flags: Array = skill.get("flags", [])
		if flag in flags:
			return true
	return false


func _find_skill(skill_id: String) -> Dictionary:
	if not skill_data.has("trees"):
		return {}
	for tree_name in skill_data["trees"].keys():
		for skill in skill_data["trees"][tree_name]:
			if skill.get("id", "") == skill_id:
				return skill
	return {}


func _save_progress() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(unlocked, "\t"))


func _load_progress() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		unlocked = parsed


func reset_all_skills() -> void:
	unlocked.clear()
	_save_progress()
