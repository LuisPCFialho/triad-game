class_name Player
extends CharacterBody2D

const MAX_HP := 100

@export var speed: float = 300.0
@export var acceleration: float = 1800.0
@export var friction: float = 1400.0
@export var shoot_interval: float = 0.2
@export var bullet_scene: PackedScene
@export var bullet_damage: int = 10
@export var dash_speed: float = 900.0
@export var dash_duration: float = 0.18
@export var dash_cooldown_time: float = 2.0
@export var invuln_time: float = 0.5

var hp: int = MAX_HP
var can_shoot: bool = true
var can_dash: bool = true
var is_dashing: bool = false
var is_invuln: bool = false
var dash_timer: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var muzzle: Marker2D = $Muzzle
@onready var shoot_cooldown: Timer = $ShootCooldown
@onready var dash_cooldown: Timer = $DashCooldown
@onready var invuln_timer: Timer = $InvulnTimer
@onready var shoot_sound: AudioStreamPlayer2D = $ShootSound


func _ready() -> void:
	add_to_group("player")
	shoot_cooldown.wait_time = shoot_interval
	dash_cooldown.wait_time = dash_cooldown_time
	invuln_timer.wait_time = invuln_time


func _physics_process(delta: float) -> void:
	if not is_dashing:
		var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if input_dir != Vector2.ZERO:
			velocity = velocity.move_toward(input_dir * speed, acceleration * delta)
		else:
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		look_at(get_global_mouse_position())
		if Input.is_action_pressed("shoot") and can_shoot:
			_shoot()
		if Input.is_action_just_pressed("dash") and can_dash:
			_start_dash()
	else:
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false
			velocity = velocity * 0.4
	move_and_slide()


func _shoot() -> void:
	if bullet_scene == null:
		return
	var bullet: Node = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = muzzle.global_position
	bullet.global_rotation = global_rotation
	if bullet.has_method("setup"):
		bullet.setup(Vector2.RIGHT.rotated(global_rotation), bullet_damage)
	can_shoot = false
	shoot_cooldown.start()
	if shoot_sound:
		shoot_sound.pitch_scale = randf_range(0.95, 1.05)
		shoot_sound.play()


func _start_dash() -> void:
	is_dashing = true
	is_invuln = true
	dash_timer = dash_duration
	var dir: Vector2 = velocity.normalized() if velocity.length() > 10.0 else Vector2.RIGHT.rotated(global_rotation)
	velocity = dir * dash_speed
	can_dash = false
	dash_cooldown.start()
	invuln_timer.start()


func take_damage(amount: int) -> void:
	if is_invuln:
		return
	hp = max(0, hp - amount)
	is_invuln = true
	invuln_timer.start()
	_flash()
	Signals.player_damaged.emit(amount, hp)
	if hp <= 0:
		Signals.player_died.emit()
		queue_free()


func heal(amount: int) -> void:
	hp = min(MAX_HP, hp + amount)
	Signals.player_healed.emit(amount)


func _flash() -> void:
	if sprite == null:
		return
	sprite.modulate = Color(2.5, 2.5, 2.5)
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.15)


func _on_shoot_cooldown_timeout() -> void:
	can_shoot = true


func _on_dash_cooldown_timeout() -> void:
	can_dash = true


func _on_invuln_timer_timeout() -> void:
	is_invuln = false
