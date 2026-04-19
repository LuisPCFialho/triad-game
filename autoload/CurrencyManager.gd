extends Node

signal currencies_changed(scrap: int, fuel: int, cores: int)
signal currency_earned(type: String, amount: int, at_position: Vector2)

const SAVE_PATH := "user://currencies.json"

var scrap: int = 0
var fuel: int = 0
var cores: int = 0

var run_scrap: int = 0
var run_fuel: int = 0
var run_cores: int = 0


func _ready() -> void:
	_load()


func reset_run_earnings() -> void:
	run_scrap = 0
	run_fuel = 0
	run_cores = 0


func add(type: String, amount: int, at_position: Vector2 = Vector2.ZERO) -> void:
	match type:
		"scrap":
			scrap += amount
			run_scrap += amount
		"fuel":
			fuel += amount
			run_fuel += amount
		"cores":
			cores += amount
			run_cores += amount
		_:
			push_warning("Unknown currency type: %s" % type)
			return
	currency_earned.emit(type, amount, at_position)
	currencies_changed.emit(scrap, fuel, cores)


func spend(cost: Dictionary) -> bool:
	var c_scrap: int = int(cost.get("scrap", 0))
	var c_fuel: int = int(cost.get("fuel", 0))
	var c_cores: int = int(cost.get("cores", 0))
	if scrap < c_scrap or fuel < c_fuel or cores < c_cores:
		return false
	scrap -= c_scrap
	fuel -= c_fuel
	cores -= c_cores
	currencies_changed.emit(scrap, fuel, cores)
	_save()
	return true


func can_afford(cost: Dictionary) -> bool:
	return (
		scrap >= int(cost.get("scrap", 0))
		and fuel >= int(cost.get("fuel", 0))
		and cores >= int(cost.get("cores", 0))
	)


func end_run_banking() -> void:
	_save()


func _save() -> void:
	var data := {"scrap": scrap, "fuel": fuel, "cores": cores}
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
	scrap = int(parsed.get("scrap", 0))
	fuel = int(parsed.get("fuel", 0))
	cores = int(parsed.get("cores", 0))
