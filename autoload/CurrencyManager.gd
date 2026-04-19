extends Node

signal currencies_changed(sparks: int, prisms: int, crystals: int)
signal currency_earned(type: String, amount: int, at_position: Vector2)

const SAVE_PATH := "user://currencies.json"

var sparks: int = 0
var prisms: int = 0
var crystals: int = 0

var run_sparks: int = 0
var run_prisms: int = 0
var run_crystals: int = 0


func _ready() -> void:
	_load()


func reset_run_earnings() -> void:
	run_sparks = 0
	run_prisms = 0
	run_crystals = 0


func add(type: String, amount: int, at_position: Vector2 = Vector2.ZERO) -> void:
	match type:
		"sparks":
			sparks += amount
			run_sparks += amount
		"prisms":
			prisms += amount
			run_prisms += amount
		"crystals":
			crystals += amount
			run_crystals += amount
		_:
			push_warning("Unknown currency type: %s" % type)
			return
	currency_earned.emit(type, amount, at_position)
	currencies_changed.emit(sparks, prisms, crystals)


func spend(cost: Dictionary) -> bool:
	var c_sparks: int = int(cost.get("sparks", 0))
	var c_prisms: int = int(cost.get("prisms", 0))
	var c_crystals: int = int(cost.get("crystals", 0))
	if sparks < c_sparks or prisms < c_prisms or crystals < c_crystals:
		return false
	sparks -= c_sparks
	prisms -= c_prisms
	crystals -= c_crystals
	currencies_changed.emit(sparks, prisms, crystals)
	_save()
	return true


func can_afford(cost: Dictionary) -> bool:
	return (
		sparks >= int(cost.get("sparks", 0))
		and prisms >= int(cost.get("prisms", 0))
		and crystals >= int(cost.get("crystals", 0))
	)


func end_run_banking() -> void:
	_save()


func _save() -> void:
	var data := {"sparks": sparks, "prisms": prisms, "crystals": crystals}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Cannot open currency save file")
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
	sparks = int(parsed.get("sparks", 0))
	prisms = int(parsed.get("prisms", 0))
	crystals = int(parsed.get("crystals", 0))
