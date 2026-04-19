extends Control


func _ready() -> void:
	var t := int(Game.run_time_seconds)
	$Center/VBox/Stats.text = (
		"Survived: %02d:%02d\nKills: %d\nBest Streak: %d\nScore: %d\n\n"
		+ "Earned: +%d Scrap  +%d Fuel  +%d Cores"
	) % [
		t / 60, t % 60, Game.enemies_killed, Game.highest_streak, Game.current_score,
		CurrencyManager.run_scrap, CurrencyManager.run_fuel, CurrencyManager.run_cores,
	]


func _on_sanctum_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/Sanctum.tscn")


func _on_retry_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
