# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Running

Open `project.godot` in Godot 4.x. No CLI build commands — use the Godot editor.

- Run scene: `F5`
- Check errors: Output panel
- Platform-specific behaviour: test on target export template

## Architecture

**Autoloads (singletons):**
- `SystemManager` (`scripts/autoload/SystemManager.gd`) — global instability value (0–100), save/load
- `SnippetBus` (`scripts/autoload/SnippetBus.gd`) — signal event bus between Player and Snippets

**Scene tree:**
```
RunScene
├── RoomContainer          ← loads CombatRoom / RewardRoom / BossRoom dynamically
├── TheDefragger           ← player (CharacterBody2D)
│   ├── Camera2D           ← screen shake
│   ├── AnimatedSprite2D   ← glitch_effect.gdshader
│   └── ShootOrigin
└── Terminal (CanvasLayer) ← HUD, opens with ` (backtick), Engine.time_scale = 0.1
```

**Snippets** — each is a `Resource` extending `BaseSnippet`. To add one:
1. Create `scripts/snippets/MySnippet.gd` extending `BaseSnippet`
2. Override `_connect_signals()` and `_disconnect_signals()`
3. Create `resources/snippets/MySnippet.tres` from Godot panel
4. Assign `.tres` in RewardRoom or KernelHub

**Shaders:**
- `resources/shaders/glitch_effect.gdshader` — per-sprite glitch
- `resources/shaders/screen_glitch.gdshader` — fullscreen, driven by `SystemManager.instability`

**Language:** GDScript for prototyping. C# is an option only for performance-critical bullet-hell logic.
