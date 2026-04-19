class_name Spawner
extends Node2D

@export var chaser_scene: PackedScene
@export var shooter_scene: PackedScene
@export var tank_scene: PackedScene

@export var arena_min: Vector2 = Vector2(40, 40)
@export var arena_max: Vector2 = Vector2(1240, 680)
@export var base_spawn_interval: float = 2.0
@export var min_spawn_interval: float = 0.35

var _spawn_timer: float = 0.0
var _elapsed: float = 0.0


func _process(delta: float) -> void:
	if not Game.run_active:
		return
	_elapsed += delta
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_batch()
		_spawn_timer = _current_interval()


func _current_interval() -> float:
	# Difficulty scales with time: interval shrinks from base to min over 6 minutes.
	var t := clamp(_elapsed / 360.0, 0.0, 1.0)
	return lerp(base_spawn_interval, min_spawn_interval, t)


func _spawn_batch() -> void:
	var batch_size := 1 + int(_elapsed / 60.0)  # +1 per minute
	for i in batch_size:
		_spawn_one()


func _spawn_one() -> void:
	var pos := _random_edge_position()
	var roll := randf()
	var scene: PackedScene
	if _elapsed < 60.0:
		scene = chaser_scene
	elif _elapsed < 180.0:
		scene = shooter_scene if roll < 0.3 else chaser_scene
	else:
		if roll < 0.15:
			scene = tank_scene
		elif roll < 0.45:
			scene = shooter_scene
		else:
			scene = chaser_scene
	if scene == null:
		return
	var enemy: Node2D = scene.instantiate()
	enemy.global_position = pos
	get_tree().current_scene.add_child(enemy)


func _random_edge_position() -> Vector2:
	var edge := randi() % 4
	match edge:
		0: return Vector2(randf_range(arena_min.x, arena_max.x), arena_min.y + 10)
		1: return Vector2(arena_max.x - 10, randf_range(arena_min.y, arena_max.y))
		2: return Vector2(randf_range(arena_min.x, arena_max.x), arena_max.y - 10)
		_: return Vector2(arena_min.x + 10, randf_range(arena_min.y, arena_max.y))
