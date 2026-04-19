extends EnemyBase

@export var explode_radius: float = 120.0
@export var explode_damage: int = 25


func _ready() -> void:
	super()
	kind = "shadow_golem"
	max_hp = 90
	hp = max_hp
	damage = 15
	speed = 70.0
	sparks_reward = 3
	crystals_reward = 1
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
	ScreenShake.shake(0.35)
	_spawn_explosion_particles()
	if player_ref and is_instance_valid(player_ref):
		var d := global_position.distance_to(player_ref.global_position)
		if d <= explode_radius and player_ref.has_method("take_damage"):
			player_ref.take_damage(explode_damage)
	for e in get_tree().get_nodes_in_group("enemies"):
		if e == self or not is_instance_valid(e):
			continue
		if global_position.distance_to(e.global_position) <= explode_radius and e.has_method("hit"):
			e.hit(explode_damage)


func _spawn_explosion_particles() -> void:
	var p := CPUParticles2D.new()
	get_tree().current_scene.add_child(p)
	p.global_position = global_position
	p.emitting = true
	p.one_shot = true
	p.explosiveness = 1.0
	p.amount = 28
	p.lifetime = 0.7
	p.initial_velocity_min = 120.0
	p.initial_velocity_max = 300.0
	p.spread = 180.0
	p.scale_amount_min = 5.0
	p.scale_amount_max = 9.0
	p.color = Color(0.5, 0.2, 0.9, 1.0)
	var t := get_tree().create_timer(1.0)
	t.timeout.connect(p.queue_free)


func _on_hitbox_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		on_touch_player(body)
