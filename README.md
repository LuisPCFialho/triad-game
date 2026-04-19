# TRIAD

Endless arena rogue-lite made in Godot 4.6. Three currencies, three skill trees, one Keeper boss.

> **Play in browser:** https://luispcfialho.github.io/triad-game/

## Concept — not another Steam clone

- **No levels.** Survive the arena for as long as you can. The Keeper spawns at 8 minutes; defeat it for victory.
- **3 currencies** that drop from different playstyles:
  - **SCRAP** (grey) — every kill (baseline).
  - **FUEL** (orange) — every 5 kills in an un-hit streak.
  - **CORES** (cyan) — kills of Tanks / Boss.
- **3 skill trees, permanent between runs** — Scrap / Fuel / Cores. Each tree has branching stat and ability nodes. Capstones require mixed currency.
- **Die → keep everything you earned.** Spend in the Sanctum, re-enter stronger. Meta-progression replaces levels.

## Controls

| Action | Keys |
|---|---|
| Move | `W A S D` / Arrow keys |
| Aim | Mouse |
| Shoot | Hold Left click |
| Dash (invuln-frames) | `Space` / `Shift` |
| Pause | `Esc` |

## Build from source

```bash
git clone https://github.com/LuisPCFialho/triad-game.git
cd triad-game
# Edit in Godot 4.6.2:
"C:/Apps/Godot/Godot.exe" --path . --editor
# Run directly:
"C:/Apps/Godot/Godot.exe" --path .
# Rebuild + redeploy web:
bash scripts/deploy-pages.sh
```

## Architecture

```
autoload/
  Game.gd            run state (score, streak, timer, death handling)
  Signals.gd         event bus (player_damaged, enemy_died, game_over, victory, ...)
  CurrencyManager.gd scrap/fuel/cores — save/load to user://currencies.json
  SkillManager.gd    loads data/skill_tree.json, tracks unlocks, provides modifiers

scenes/
  Main.tscn          arena + player + spawner + HUD + pause overlay
  player/            Player, Bullet
  enemies/           EnemyBase + Chaser / Shooter / Tank / Boss + EnemyBullet
  world/             Arena (bounded), Spawner (time-scaled difficulty + boss at 8min)
  ui/                MainMenu, Sanctum (skill tree UI), HUD, PauseMenu, GameOver, Victory

data/
  skill_tree.json    data-driven — 20 skills across 3 trees with prereqs + effects
```

## Tuning knobs (where to tweak)

- **Spawner.gd** — `base_spawn_interval`, `min_spawn_interval`, `boss_time_seconds`
- **Player.gd** — `BASE_*` constants, `dash_speed`, `dash_duration`
- **skill_tree.json** — add/modify skills, costs, effects
- **Game.gd** — `STREAK_MILESTONE` (default 5 kills per Fuel)

## Credits

- Sprites: [Kenney Top-Down Shooter](https://kenney.nl/assets/top-down-shooter) + [Tiny Dungeon](https://kenney.nl/assets/tiny-dungeon) (CC0)
- Audio: [Kenney Sci-Fi Sounds](https://kenney.nl/assets/sci-fi-sounds) + [UI Audio](https://kenney.nl/assets/ui-audio) (CC0)
- Code: MIT.
