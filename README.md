# LUMINA

Endless arena rogue-lite made in Godot 4.6. Kid-friendly magical world. Light vs Shadow.

> **Play in browser:** https://luispcfialho.github.io/triad-game/

## Concept

- **No levels.** Survive the crystal arena as long as you can. The Dark Keeper spawns at 8 minutes — defeat it for victory.
- **3 currencies** earned through different playstyles:
  - **SPARKS** ✦ (grey) — every shadow banished (baseline).
  - **PRISMS** ◈ (purple) — every 5 kills in an un-hit streak.
  - **CRYSTALS** ❋ (cyan) — kills of Shadow Golems / Dark Keeper.
- **3 skill trees, permanent between runs** — Sparks / Prisms / Crystals. Each tree has branching stat and ability nodes. Capstones require mixed currency.
- **Die → keep everything you earned.** Spend in the Sanctum of Light, re-enter stronger.

## Controls

| Action | Keys |
|---|---|
| Move | `W A S D` / Arrow keys |
| Aim | Mouse |
| Cast | Hold Left click |
| Blink (invuln-frames) | `Space` / `Shift` |
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
  Signals.gd         event bus
  CurrencyManager.gd sparks/prisms/crystals — save/load to user://currencies.json
  SkillManager.gd    loads data/skill_tree.json, tracks unlocks, provides modifiers
  ScreenShake.gd     trauma-based camera shake singleton

scenes/
  Main.tscn          arena + player + spawner + HUD + pause overlay
  player/            Player (light guardian wizard), Bullet (light orb)
  enemies/           EnemyBase + ShadowBlob / ShadowImp / ShadowGolem / DarkKeeper + ShadowOrb
  world/             Arena (crystal cave), Spawner (time-scaled difficulty + boss at 8 min)
  ui/                MainMenu, Sanctum (skill tree UI), HUD, PauseMenu, GameOver, Victory

data/
  skill_tree.json    data-driven — 20 skills across 3 trees with prereqs + effects

assets/
  sprites/           AI-generated pixel art (Pollinations / Kenney CC0)
  audio/             Kenney Sci-Fi + UI Audio (CC0)
```

## Tuning knobs

- **Spawner.gd** — `base_spawn_interval`, `min_spawn_interval`, `boss_time_seconds`
- **Player.gd** — `BASE_*` constants, `dash_speed`, `dash_duration`
- **skill_tree.json** — add/modify skills, costs, effects
- **Game.gd** — `STREAK_MILESTONE` (default 5 kills per Prism)

## Credits

- Sprites: AI-generated pixel art (Pollinations) + [Kenney Top-Down Shooter](https://kenney.nl/assets/top-down-shooter) (CC0)
- Audio: [Kenney Sci-Fi Sounds](https://kenney.nl/assets/sci-fi-sounds) + [UI Audio](https://kenney.nl/assets/ui-audio) (CC0)
- Code: MIT.
