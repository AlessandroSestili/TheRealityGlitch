# the-reality-glitch

Open `project.godot` in Godot 4.x. Run: F5. No CLI build.

## Architecture
Autoloads: `SystemManager` (instability 0–100, save/load), `SnippetBus` (signal bus Player↔Snippets).

Scene: `RunScene → RoomContainer` (loads rooms dynamically) + `TheDefragger` (player, Camera2D, AnimatedSprite2D w/ glitch shader, ShootOrigin) + `Terminal` (HUD, `` ` `` opens, time_scale=0.1).

Snippets — `Resource` extending `BaseSnippet`: create `.gd` in `scripts/snippets/`, override `_connect/_disconnect_signals()`, create `.tres`, assign in RewardRoom/KernelHub.

Shaders: `glitch_effect.gdshader` (per-sprite), `screen_glitch.gdshader` (fullscreen, driven by instability).

GDScript for prototyping. C# only for perf-critical bullet-hell.
