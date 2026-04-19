class_name EnemyBase
extends CharacterBody2D

@export var max_hp: int = 20
@export var damage: int = 10
@export var speed: float = 100.0
@export var kind: String = "blob"
@export var sparks_reward: int = 1
@export var crystals_reward: int = 0
@export var score_value: int = 10

var hp: int
var player_ref: Node2D = null

@onready var sprite: Sprite2D = $Sprite2D
@onready var hitbox: Area2D = $Hitbox


func _ready() -> void:
	hp = max_hp
	add_to_group("enemies")
	if hitbox and not hitbox.is_in_group("enemy_hitbox"):
		hitbox.add_to_group("enemy_hitbox")
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_ref = players[0]


func _physics_process(delta: float) -> void:
	if player_ref == null or not is_instance_valid(player_ref):
		return
	_tick_ai(delta)
	move_and_slide()
	_face_velocity_or_player()


func _tick_ai(_delta: float) -> void:
	pass


func _face_velocity_or_player() -> void:
	if player_ref and is_instance_valid(player_ref):
		look_at(player_ref.global_position)


func hit(amount: int) -> void:
	hp -= amount
	_flash()
	Signals.enemy_damaged.emit(self, amount)
	if hp <= 0:
		_die()


func _flash() -> void:
	if sprite == null:
		return
	sprite.modulate = Color(3.0, 0.4, 3.0)
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.14)


func _die() -> void:
	_spawn_death_particles()
	CurrencyManager.add("sparks", sparks_reward, global_position)
	if crystals_reward > 0:
		CurrencyManager.add("crystals", crystals_reward, global_position)
	Signals.enemy_died.emit(global_position, score_value)
	Game.add_score(score_value)
	Game.enemies_killed += 1
	Game.register_kill(global_position, kind)
	queue_free()


func _spawn_death_particles() -> void:
	var p := CPUParticles2D.new()
	get_tree().current_scene.add_child(p)
	p.global_position = global_position
	p.emitting = true
	p.one_shot = true
	p.explosiveness = 0.95
	p.amount = 14
	p.lifetime = 0.5
	p.initial_velocity_min = 60.0
	p.initial_velocity_max = 180.0
	p.spread = 180.0
	p.scale_amount_min = 3.0
	p.scale_amount_max = 6.0
	p.color = Color(0.65, 0.3, 1.0, 1.0)
	var t := get_tree().create_timer(0.7)
	t.timeout.connect(p.queue_free)


func _on_hitbox_area_entered(_area: Area2D) -> void:
	pass


func on_touch_player(player: Node) -> void:
	if player.has_method("take_damage"):
		player.take_damage(damage)
