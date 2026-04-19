extends Control


func _ready() -> void:
	var t := int(Game.run_time_seconds)
	$Center/VBox/Stats.text = (
		"Fallen in %02d:%02d\nShadows banished: %d\nBest streak: %d\nScore: %d\n\n"
		+ "Earned: +%d ✦Sparks  +%d ◈Prisms  +%d ❋Crystals"
	) % [
		t / 60, t % 60, Game.enemies_killed, Game.highest_streak, Game.current_score,
		CurrencyManager.run_sparks, CurrencyManager.run_prisms, CurrencyManager.run_crystals,
	]


func _on_sanctum_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/Sanctum.tscn")


func _on_retry_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
