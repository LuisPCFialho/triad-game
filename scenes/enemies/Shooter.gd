extends EnemyBase

@export var prefer_distance: float = 320.0
@export var shoot_interval: float = 1.2
@export var bullet_scene: PackedScene

var _shoot_timer: float = 0.0


func _ready() -> void:
	super()
	kind = "shooter"
	max_hp = 30
	hp = max_hp
	damage = 8
	speed = 100.0
	scrap_reward = 2
	score_value = 20
	_shoot_timer = randf_range(0.3, shoot_interval)


func _tick_ai(delta: float) -> void:
	if player_ref == null:
		return
	var to_player := player_ref.global_position - global_position
	var dist := to_player.length()
	var dir := to_player.normalized()
	if dist > prefer_distance + 30.0:
		velocity = dir * speed
	elif dist < prefer_distance - 30.0:
		velocity = -dir * speed
	else:
		velocity = velocity.lerp(Vector2.ZERO, 0.2)
	_shoot_timer -= delta
	if _shoot_timer <= 0.0 and dist < 600.0:
		_shoot(dir)
		_shoot_timer = shoot_interval


func _shoot(direction: Vector2) -> void:
	if bullet_scene == null:
		return
	var bullet: Node = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position + direction * 24.0
	if bullet.has_method("setup"):
		bullet.setup(direction, damage)
