extends Node

signal player_damaged(amount: int, hp_remaining: int)
signal player_died
signal player_healed(amount: int)

signal enemy_damaged(enemy: Node2D, amount: int)
signal enemy_died(position: Vector2, points: int)

signal wave_started(wave_num: int)
signal wave_cleared(wave_num: int)

signal upgrade_offered(choices: Array)
signal upgrade_selected(upgrade_id: String)

signal pickup_collected(type: String, value: int)

signal score_changed(new_score: int)
signal game_over
signal victory
