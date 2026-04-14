# THE REALITY GLITCH — Game Design Document

## 1. VISIONE TECNICA

| Campo | Scelta |
|-------|--------|
| Engine | Godot 4.x |
| Linguaggio | GDScript (prototipazione) + C# opzionale per bullet-hell |
| Rendering | Forward+ (shader avanzati) — fallback Compatibility per Steam Deck |
| Stile | Pixel Art + Custom Shaders (distorsione, aberrazione cromatica, glitch) |

---

## 2. ARCHITETTURA GODOT (Scene Tree)

```
Root
├── SystemManager (Autoload) — instabilità, stato globale, save/load
├── SnippetBus    (Autoload) — event bus segnali Player ↔ Snippet
├── RunScene
│   ├── RoomContainer
│   │   └── [CombatRoom | RewardRoom | BossRoom] (caricata dinamicamente)
│   ├── TheDefragger (CharacterBody2D)
│   │   ├── Camera2D         ← screen shake
│   │   ├── AnimatedSprite2D ← shader glitch_effect.gdshader
│   │   ├── ShootOrigin (Marker2D)
│   │   └── HurtFlash (ColorRect)
│   └── Terminal (CanvasLayer)
│       └── Container (Control)
│           ├── SnippetList (ItemList)
│           ├── EquippedList (ItemList)
│           ├── DescLabel
│           └── InstabilityBar (ProgressBar)
└── KernelHub (scena meta-game tra le run)
```

---

## 3. MECCANICA CORE: SCM (Source Code Manipulation)

### Pattern Strategy — Snippet come Resource

Ogni Snippet è una `Resource` personalizzata che estende `BaseSnippet`.  
Il Terminale si apre con **`** (backtick) → `Engine.time_scale = 0.1` (slow-motion).

### Snippet implementati

| File | Trigger | Effetto |
|------|---------|---------|
| `FireTrailSnippet.gd` | `on_dash` | Particelle di fuoco al dash |
| `RicochetSnippet.gd` | `on_shoot` | Proiettili rimbalzano N volte |

### Aggiungere un nuovo Snippet

1. Crea `scripts/snippets/MioSnippet.gd` che estende `BaseSnippet`
2. Sovrascrivi `_connect_signals()` e `_disconnect_signals()`
3. Crea `resources/snippets/MioSnippet.tres` dal pannello Godot
4. Assegna la .tres nella RewardRoom o nell'Hub

---

## 4. SISTEMA DI INSTABILITÀ (The Kernel Panic)

Valore 0–100 gestito da `SystemManager.instability`.

| Soglia | Effetto Visivo | Effetto AI |
|--------|----------------|------------|
| 25% | Leggero jitter UV schermo | — |
| 50% | Blocchi di distorsione orizzontale | Nemici più veloci |
| 75% | Aberrazione cromatica schermo intero | Nemici si teletrasportano |
| 100% | Vignette rossa + inversione parziale | Kernel Panic → morte |

Shader: `resources/shaders/screen_glitch.gdshader` (applicato al CanvasLayer globale).

---

## 5. STRUTTURA DELLE RUN (File System)

Generata da `RoomGenerator.gd` con algoritmo a nodi pesati.

| Scena | Tipo | Probabilità |
|-------|------|-------------|
| `CombatRoom.tscn` | Combat.exe | 70% |
| `RewardRoom.tscn` | Reward.zip | 30% |
| `BossRoom.tscn` | Boss_Daemon.sh | ogni 5 stanze |

---

## 6. META-GAME: THE KERNEL HUB

Upgrade acquistabili con **Frammenti di Dati** (XP da nemici uccisi).

| Upgrade | Effetto | Costi (Lv 1/2/3) |
|---------|---------|------------------|
| Update RAM | +1 slot Snippet equipaggiabile | 100 / 200 / 400 |
| Update CPU | –10% cooldown abilità attive per livello | 150 / 300 / 600 |
| Stable Firmware | –10% velocità crescita instabilità per livello | 120 / 250 / 500 |

---

## 7. COMBAT

- Proiettili: `Area2D` con `Bullet.gd` — supporta rimbalzi via `set_bounces(n)`
- Laser: `RayCast2D` (da implementare)
- Hitbox nemici: `Area2D` nel gruppo `"enemy"`
- Muri: nodi `StaticBody2D` nel gruppo `"wall"`

---

## 8. STRUTTURA FILE

```
TheRealityGlitch/
├── project.godot
├── scripts/
│   ├── autoload/
│   │   ├── SystemManager.gd
│   │   └── SnippetBus.gd
│   ├── player/
│   │   ├── Defragger.gd
│   │   └── Bullet.gd
│   ├── enemies/
│   │   └── BaseEnemy.gd
│   ├── snippets/
│   │   ├── BaseSnippet.gd
│   │   ├── FireTrailSnippet.gd
│   │   └── RicochetSnippet.gd
│   ├── rooms/
│   │   └── RoomGenerator.gd
│   └── ui/
│       ├── Terminal.gd
│       └── KernelHub.gd
├── resources/
│   ├── shaders/
│   │   ├── glitch_effect.gdshader   ← per sprite
│   │   └── screen_glitch.gdshader  ← per schermo intero
│   ├── snippets/                    ← file .tres delle risorse
│   └── hardware/
├── scenes/
│   ├── player/
│   ├── enemies/
│   ├── rooms/
│   ├── ui/
│   └── hub/
└── assets/
    ├── sprites/
    ├── sounds/
    ├── music/
    └── fonts/
```
