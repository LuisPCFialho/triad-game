extends EnemyBase

@export var explode_radius: float = 120.0
@export var explode_damage: int = 25


func _ready() -> void:
	super()
	kind = "tank"
	max_hp = 90
	hp = max_hp
	damage = 15
	speed = 70.0
	scrap_reward = 3
	cores_reward = 1
	score_value = 50


func _tick_ai(_delta: float) -> void:
	if player_ref == null:
		return
	var dir := (player_ref.global_position - global_position).normalized()
	velocity = dir * speed


func _die() -> void:
	_explode()
	super()


func _explode() -> void:
	if player_ref and is_instance_valid(player_ref):
		var d := global_position.distance_to(player_ref.global_position)
		if d <= explode_radius and player_ref.has_method("take_damage"):
			player_ref.take_damage(explode_damage)
	for e in get_tree().get_nodes_in_group("enemies"):
		if e == self or not is_instance_valid(e):
			continue
		if global_position.distance_to(e.global_position) <= explode_radius and e.has_method("hit"):
			e.hit(explode_damage)


func _on_hitbox_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		on_touch_player(body)
