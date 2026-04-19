extends CanvasLayer

@onready var hp_bar: ProgressBar = $Panel/HBox/HPBar
@onready var hp_label: Label = $Panel/HBox/HPBar/HPLabel
@onready var sparks_label: Label = $Panel/HBox/Currencies/Sparks
@onready var prisms_label: Label = $Panel/HBox/Currencies/Prisms
@onready var crystals_label: Label = $Panel/HBox/Currencies/Crystals
@onready var streak_label: Label = $Panel/HBox/Streak
@onready var timer_label: Label = $Panel/HBox/Timer
@onready var toast_label: Label = $Toast


func _ready() -> void:
	Signals.player_damaged.connect(_update_hp)
	Signals.player_healed.connect(func(_a): _refresh_hp())
	CurrencyManager.currencies_changed.connect(_update_currencies)
	CurrencyManager.currency_earned.connect(_on_currency_earned)
	_update_currencies(CurrencyManager.sparks, CurrencyManager.prisms, CurrencyManager.crystals)
	_refresh_hp()


func _process(_delta: float) -> void:
	var t := int(Game.run_time_seconds)
	timer_label.text = "%02d:%02d" % [t / 60, t % 60]
	streak_label.text = "Streak: %d" % Game.kill_streak


func _refresh_hp() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() == 0:
		return
	var p = players[0]
	if "hp" in p and "MAX_HP" in p:
		hp_bar.max_value = p.MAX_HP
		hp_bar.value = p.hp
		hp_label.text = "%d / %d" % [p.hp, p.MAX_HP]


func _update_hp(_amount: int, hp_remaining: int) -> void:
	hp_bar.value = hp_remaining
	hp_label.text = "%d / %d" % [hp_remaining, int(hp_bar.max_value)]


func _update_currencies(s: int, p: int, c: int) -> void:
	sparks_label.text = "✦ %d" % s
	prisms_label.text = "◈ %d" % p
	crystals_label.text = "❋ %d" % c


func _on_currency_earned(type: String, amount: int, _pos: Vector2) -> void:
	var icon := {"sparks": "✦", "prisms": "◈", "crystals": "❋"}.get(type, "+")
	toast_label.text = "+%d %s %s" % [amount, icon, type.capitalize()]
	toast_label.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_property(toast_label, "modulate:a", 0.0, 1.4)
