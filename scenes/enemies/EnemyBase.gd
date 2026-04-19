class_name EnemyBase
extends CharacterBody2D

@export var max_hp: int = 20
@export var damage: int = 10
@export var speed: float = 100.0
@export var kind: String = "chaser"
@export var scrap_reward: int = 1
@export var cores_reward: int = 0
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
	# Find player once
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
	pass  # Override in subclasses


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
	sprite.modulate = Color(3.0, 0.5, 0.5)
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.12)


func _die() -> void:
	CurrencyManager.add("scrap", scrap_reward, global_position)
	if cores_reward > 0:
		CurrencyManager.add("cores", cores_reward, global_position)
	Signals.enemy_died.emit(global_position, score_value)
	Game.add_score(score_value)
	Game.enemies_killed += 1
	Game.register_kill(global_position, kind)
	queue_free()


func _on_hitbox_area_entered(_area: Area2D) -> void:
	pass


func on_touch_player(player: Node) -> void:
	if player.has_method("take_damage"):
		player.take_damage(damage)
