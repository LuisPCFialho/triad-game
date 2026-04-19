extends EnemyBase

@export var bullet_scene: PackedScene
@export var burst_interval: float = 2.2
@export var charge_interval: float = 6.0
@export var charge_speed: float = 420.0

var _burst_timer: float = 2.0
var _charge_timer: float = 5.0
var _is_charging: bool = false
var _charge_dir: Vector2 = Vector2.ZERO
var _charge_duration_left: float = 0.0


func _ready() -> void:
	super()
	kind = "dark_keeper"
	max_hp = 600
	hp = max_hp
	damage = 20
	speed = 80.0
	sparks_reward = 20
	crystals_reward = 10
	score_value = 500
	add_to_group("boss")


func _tick_ai(delta: float) -> void:
	if player_ref == null:
		return
	if _is_charging:
		velocity = _charge_dir * charge_speed
		_charge_duration_left -= delta
		if _charge_duration_left <= 0.0:
			_is_charging = false
		return
	var dir := (player_ref.global_position - global_position).normalized()
	velocity = dir * speed
	_burst_timer -= delta
	_charge_timer -= delta
	if _burst_timer <= 0.0:
		_burst_timer = burst_interval
		_fire_ring()
	if _charge_timer <= 0.0:
		_charge_timer = charge_interval
		_start_charge()


func _fire_ring() -> void:
	if bullet_scene == null:
		return
	var count := 12
	for i in count:
		var angle := TAU * float(i) / float(count)
		var d := Vector2.RIGHT.rotated(angle)
		var b: Node = bullet_scene.instantiate()
		get_tree().current_scene.add_child(b)
		b.global_position = global_position + d * 40.0
		if b.has_method("setup"):
			b.setup(d, 12)
	ScreenShake.shake(0.3)


func _start_charge() -> void:
	if player_ref == null:
		return
	_is_charging = true
	_charge_dir = (player_ref.global_position - global_position).normalized()
	_charge_duration_left = 0.7


func _die() -> void:
	ScreenShake.shake(0.8)
	_spawn_death_burst()
	super()
	Signals.victory.emit()


func _spawn_death_burst() -> void:
	var p := CPUParticles2D.new()
	get_tree().current_scene.add_child(p)
	p.global_position = global_position
	p.emitting = true
	p.one_shot = true
	p.explosiveness = 1.0
	p.amount = 60
	p.lifetime = 1.2
	p.initial_velocity_min = 100.0
	p.initial_velocity_max = 380.0
	p.spread = 180.0
	p.scale_amount_min = 4.0
	p.scale_amount_max = 10.0
	p.color = Color(0.7, 0.2, 1.0, 1.0)
	var t := get_tree().create_timer(1.5)
	t.timeout.connect(p.queue_free)


func _on_hitbox_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		on_touch_player(body)
