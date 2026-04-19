extends EnemyBase

@export var touch_damage_cooldown: float = 0.6
var _touch_timer: float = 0.0


func _ready() -> void:
	super()
	kind = "chaser"
	max_hp = 20
	hp = max_hp
	damage = 10
	speed = 140.0
	scrap_reward = 1
	score_value = 10


func _tick_ai(delta: float) -> void:
	if player_ref == null:
		return
	var dir := (player_ref.global_position - global_position).normalized()
	velocity = dir * speed
	_touch_timer -= delta


func _on_hitbox_body_entered(body: Node) -> void:
	if body.is_in_group("player") and _touch_timer <= 0.0:
		on_touch_player(body)
		_touch_timer = touch_damage_cooldown
