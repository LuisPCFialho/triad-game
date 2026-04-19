extends Node2D


func _ready() -> void:
	Game.reset_run()
	if not Signals.game_over.is_connected(_on_game_over):
		Signals.game_over.connect(_on_game_over)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().change_scene_to_file("res://scenes/ui/Sanctum.tscn")


func _on_game_over() -> void:
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/ui/GameOver.tscn")
