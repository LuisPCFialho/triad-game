extends Node

var _trauma: float = 0.0
var _decay: float = 2.4
var _max_offset := Vector2(14.0, 10.0)
var _max_rot_deg := 2.0

var _camera: Camera2D = null


func shake(amount: float = 0.5) -> void:
	_trauma = min(1.0, _trauma + amount)


func _process(delta: float) -> void:
	if _camera == null:
		_camera = get_tree().get_first_node_in_group("main_camera") as Camera2D
		return
	if _trauma <= 0.0:
		_camera.offset = Vector2.ZERO
		_camera.rotation = 0.0
		return
	_trauma = max(0.0, _trauma - _decay * delta)
	var s := _trauma * _trauma
	_camera.offset = Vector2(
		_max_offset.x * s * randf_range(-1.0, 1.0),
		_max_offset.y * s * randf_range(-1.0, 1.0)
	)
	_camera.rotation = deg_to_rad(_max_rot_deg * s * randf_range(-1.0, 1.0))
