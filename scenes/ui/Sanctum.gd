extends Control

const TREES := ["scrap", "fuel", "cores"]
const TREE_COLORS := {
	"scrap": Color(0.85, 0.85, 0.85),
	"fuel": Color(1.0, 0.7, 0.2),
	"cores": Color(0.4, 0.9, 0.9),
}

@onready var scrap_panel: Container = $Margin/VBox/Trees/ScrapPanel/Nodes
@onready var fuel_panel: Container = $Margin/VBox/Trees/FuelPanel/Nodes
@onready var cores_panel: Container = $Margin/VBox/Trees/CoresPanel/Nodes
@onready var currency_label: Label = $Margin/VBox/Header/Currencies
@onready var info_label: Label = $Margin/VBox/Footer/Info


func _ready() -> void:
	CurrencyManager.currencies_changed.connect(_refresh_currencies)
	SkillManager.skill_unlocked.connect(_on_unlock)
	_refresh_currencies(CurrencyManager.scrap, CurrencyManager.fuel, CurrencyManager.cores)
	_build_tree("scrap", scrap_panel)
	_build_tree("fuel", fuel_panel)
	_build_tree("cores", cores_panel)
	info_label.text = "Select a skill to see details. Gray = locked (prereq missing). Blue = affordable. Green = unlocked."


func _refresh_currencies(s: int, f: int, c: int) -> void:
	currency_label.text = "SCRAP %d   FUEL %d   CORES %d" % [s, f, c]


func _build_tree(tree_name: String, container: Container) -> void:
	for child in container.get_children():
		child.queue_free()
	var skills := SkillManager.get_tree_skills(tree_name)
	for skill in skills:
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(240, 72)
		btn.text = _skill_label(skill)
		btn.add_theme_color_override("font_color", TREE_COLORS[tree_name])
		btn.pressed.connect(_on_skill_pressed.bind(skill.get("id", ""), tree_name))
		btn.mouse_entered.connect(func(): _show_info(skill))
		_style_button(btn, skill)
		container.add_child(btn)


func _skill_label(skill: Dictionary) -> String:
	var id: String = skill.get("id", "")
	var name: String = skill.get("name", "?")
	var cost: Dictionary = skill.get("cost", {})
	var cost_s := ""
	for k in ["scrap", "fuel", "cores"]:
		if cost.has(k):
			cost_s += "  %d %s" % [cost[k], k[0].to_upper()]
	var prefix := "[✓] " if SkillManager.has(id) else ""
	return "%s%s\n%s" % [prefix, name, cost_s.strip_edges()]


func _style_button(btn: Button, skill: Dictionary) -> void:
	var id: String = skill.get("id", "")
	if SkillManager.has(id):
		btn.modulate = Color(0.6, 1.0, 0.6)
	elif SkillManager.can_unlock(id):
		btn.modulate = Color(0.7, 0.85, 1.0)
	else:
		btn.modulate = Color(0.55, 0.55, 0.55)


func _show_info(skill: Dictionary) -> void:
	info_label.text = "%s — %s" % [skill.get("name", "?"), skill.get("desc", "")]


func _on_skill_pressed(skill_id: String, tree_name: String) -> void:
	if SkillManager.try_unlock(skill_id):
		_rebuild_all()


func _on_unlock(_skill_id: String) -> void:
	_rebuild_all()


func _rebuild_all() -> void:
	_build_tree("scrap", scrap_panel)
	_build_tree("fuel", fuel_panel)
	_build_tree("cores", cores_panel)


func _on_start_run_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
