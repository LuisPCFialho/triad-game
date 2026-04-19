extends Area2D

@export var speed: float = 450.0
@export var lifetime: float = 3.0

var velocity: Vector2 = Vector2.ZERO
var damage: int = 10
var _age: float = 0.0


func setup(direction: Vector2, dmg: int) -> void:
	velocity = direction.normalized() * speed
	damage = dmg


func _physics_process(delta: float) -> void:
	global_position += velocity * delta
	_age += delta
	if _age >= lifetime:
		queue_free()


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("walls"):
		queue_free()
	elif body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
