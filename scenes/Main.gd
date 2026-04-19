extends Node2D


func _ready() -> void:
	$Camera2D.add_to_group("main_camera")
	Game.reset_run()
	if not Signals.game_over.is_connected(_on_game_over):
		Signals.game_over.connect(_on_game_over)
	if not Signals.victory.is_connected(_on_victory):
		Signals.victory.connect(_on_victory)


func _on_victory() -> void:
	Game.run_active = false
	CurrencyManager.end_run_banking()
	Game.record_run()
	await get_tree().create_timer(1.2).timeout
	get_tree().change_scene_to_file("res://scenes/ui/Victory.tscn")


func _on_game_over() -> void:
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/ui/GameOver.tscn")
