# Bellum Aetatum — Milestones

## Milestone 1 — Architecture Validation

### Objective

Validate the core architecture by implementing a minimal playable scene that demonstrates data-driven loading and unit spawning.

### What Was Implemented

#### 1. Project Setup

- Created a Godot 4.4 project (`project.godot`) with `gl_compatibility` renderer.
- Viewport: 1152x648.
- Main scene: `res://scenes/battle_scene.tscn`.

#### 2. BattleScene

- Displays a **Player Base** (blue rectangle, left) and an **Enemy Base** (red rectangle, right).
- Empty battlefield space between them.
- A bottom UI bar with 10 dynamically generated card buttons.
- Card buttons are created programmatically from the player deck JSON, not placed manually.

#### 3. Data-Driven Decks

- **Card database** (`data/cards/cards.json`): 10 cards, each with `id`, `name`, `image`, and `stats` (hp, attack, range, speed, cost).
- **Player deck** (`data/decks/player_deck.json`): references all 10 cards by id.
- **Enemy deck** (`data/decks/enemy_deck.json`): references 8 cards by id. Loaded but not used yet.

#### 4. Unit Spawning

- Clicking a card button spawns a **Unit** near the player base.
- The Unit scene displays the card's image and name.
- Multiple units can coexist on the battlefield.
- No movement, no combat, no collision.

#### 5. Stage Configuration

- Stage loaded from `data/stages/stage_001.json`.
- Contains: `battlefield_width`, `player_spawn_position`, `enemy_spawn_position`, `background`.

#### 6. Autoloads

| Singleton | Script | Purpose |
|---|---|---|
| `JsonLoader` | `autoload/json_loader.gd` | Reads JSON files, returns parsed data |
| `DeckManager` | `autoload/deck_manager.gd` | Loads card database and resolves deck lists |

### Files Created

```
project.godot
README.md
MILESTONES.md
scenes/battle_scene.tscn
scenes/unit.tscn
scripts/battle_scene.gd
scripts/spawn_manager.gd
scripts/unit.gd
autoload/json_loader.gd
autoload/deck_manager.gd
data/cards/cards.json
data/decks/player_deck.json
data/decks/enemy_deck.json
data/stages/stage_001.json
```

### SOLID Compliance

#### Single Responsibility

- `JsonLoader` only reads and parses JSON. It has no knowledge of cards, decks, or stages.
- `DeckManager` only resolves card ids into card dictionaries. It does not spawn units or manage UI.
- `SpawnManager` only instantiates Unit scenes. It does not load data or manage positions.
- `Unit` only displays its own visuals. It does not interact with other units or the scene.
- `BattleScene` only coordinates the above. It does not contain business logic.

#### Open/Closed

- Adding a new card requires editing only `cards.json` and the deck file. No script changes.
- Adding a new stage requires only a new JSON file in `data/stages/`.
- The card button UI adapts to any deck size without code changes.

#### Dependency Inversion

- `BattleScene` depends on `DeckManager` and `SpawnManager` (abstractions), not on raw JSON or scene files.
- `DeckManager` depends on `JsonLoader` (abstraction), not on `FileAccess` directly.
- `SpawnManager` receives a `PackedScene` via constructor injection, not hardcoded paths.

### Architecture Rules Applied

| Rule | How |
|---|---|
| Classes under 250 lines | Largest script is `battle_scene.gd` at ~130 lines |
| Functions under 30 lines | All functions are short and focused |
| No static methods | All methods are instance methods |
| Signals over tight coupling | Future milestones will use signals; current milestone uses constructor injection |
| Single responsibility per scene | `unit.tscn` = one unit, `battle_scene.tscn` = battlefield |
| Reusable scripts | `Unit` and `SpawnManager` work with any card data |
| No duplicated JSON parsing | Only `JsonLoader.load_json()` handles parsing |
| No hardcoded game values | All positions, sizes, and card data come from JSON |
| Factories over switches | `SpawnManager` is a factory for Unit instances |
| Dependencies point inward | Scene -> Managers -> JsonLoader |

### What Was NOT Implemented (Intentionally)

- Movement
- Combat
- AI / pathfinding
- Abilities / effects
- Legendary units
- Animations
- Menus / settings
- Save system
- Localization
- Audio / particles
- Networking / physics

### Extension Points for Future Milestones

- `Unit` can be extended to support movement, combat, and animations.
- `SpawnManager` can be extended to support enemy spawning and object pooling.
- `DeckManager` can be extended to support deck building, shuffling, and draw mechanics.
- `BattleScene` can be extended to support waves, turns, and victory conditions.
- Stage JSON can be extended with new fields (e.g., enemy waves, terrain) without breaking existing code.

---

## Milestone 2 — Unit Movement

### Objective

Implement automatic unit movement from player base to enemy base using data-driven configuration.

### What Was Implemented

#### 1. Movement Logic in Unit

- Units automatically move from spawn position toward enemy spawn position.
- Movement begins immediately after spawning.
- Speed comes from the card's `stats.speed` field (pixels per second).
- Direction is calculated from spawn position to target position.
- Movement stops when unit reaches the enemy spawn position (within 2 pixels).
- Movement is framerate independent using `delta` time in `_physics_process`.

#### 2. Data-Driven Configuration

- Movement speed: read from `stats.speed` in card JSON.
- Target position: read from `enemy_spawn_position` in stage JSON.
- Spawn position: read from `player_spawn_position` in stage JSON.
- No hardcoded positions or speeds.

#### 3. Independent Movement

- Each unit moves independently toward the target.
- Multiple units can exist and move simultaneously.
- Units may overlap (no collision).
- Units ignore each other completely.

#### 4. Debug Output

- Unit position is logged to console every 100 pixels of horizontal movement.
- Debug output is disabled in editor mode.
- No UI debug information displayed.

### Files Modified

| File | Changes | Reason |
|---|---|---|
| `scripts/unit.gd` | +51 lines | Added movement logic: `_physics_process`, direction calculation, speed extraction, arrival detection, debug logging |
| `scripts/spawn_manager.gd` | +1 parameter | Added `target_position` parameter to pass destination to Unit after spawning |
| `scripts/battle_scene.gd` | +3 lines | Reads `enemy_spawn_position` from stage data and passes it to SpawnManager |

### Movement Flow

```
BattleScene._on_card_pressed()
  -> reads enemy_spawn_position from stage
  -> SpawnManager.spawn_unit(card, pos, target, parent)
       -> Unit.initialize(card)           // extracts speed from JSON
       -> Unit.configure_movement(target) // calculates direction
       -> _physics_process(delta)         // moves every frame
            -> _move()                    // position += direction * speed * delta
            -> _check_arrival()           // stops when reaching target
```

### Architecture Compliance

#### Single Responsibility Principle

- **Unit**: Owns all movement logic. Knows its speed, direction, and target.
- **SpawnManager**: Factory that configures Unit with movement parameters.
- **BattleScene**: Only reads stage data and coordinates spawning. No movement logic.

#### Open/Closed Principle

- Movement behavior can be extended (e.g., different movement patterns) without modifying existing code.
- New units automatically inherit movement by reading speed from JSON.

#### No Hardcoded Values

- Speed: `stats.speed` from card JSON (e.g., 120 pixels/second).
- Target: `enemy_spawn_position` from stage JSON.
- Spawn: `player_spawn_position` from stage JSON.

#### Framerate Independence

- Uses `_physics_process(delta)` with delta time.
- Movement formula: `position += direction * speed * delta`.

### SOLID Compliance

| Principle | How |
|---|---|
| Single Responsibility | Movement lives 100% in Unit. BattleScene only coordinates. |
| Open/Closed | New movement patterns can be added without modifying existing code. |
| Liskov Substitution | Unit can be extended with different movement behaviors. |
| Interface Segregation | Unit only exposes `configure_movement()` for movement setup. |
| Dependency Inversion | Unit depends on data (Dictionary), not on concrete implementations. |

### Architecture Rules Applied

| Rule | How |
|---|---|
| Classes under 250 lines | `unit.gd` is 112 lines, `spawn_manager.gd` is 17 lines, `battle_scene.gd` is 154 lines |
| Functions under 30 lines | All movement functions are 1-5 lines |
| No static methods | All methods are instance methods |
| Single responsibility per scene | Unit owns movement, BattleScene owns coordination |
| Reusable scripts | Unit works with any card data and any stage configuration |
| No hardcoded game values | Speed and positions come from JSON |
| Dependencies point inward | BattleScene -> SpawnManager -> Unit |

### What Was NOT Implemented (Intentionally)

- Combat
- Collision detection
- Pathfinding
- AI behavior
- Formation mechanics
- Attack mechanics
- Health reduction
- Abilities / effects
- Animations
- Particles
- Legendary mechanics

### Extension Points for Future Milestones

- `Unit._physics_process()` can be extended to support state machines (idle, moving, attacking, dying).
- `Unit._move()` can be replaced with pathfinding algorithms.
- `Unit._check_arrival()` can trigger combat or other behaviors.
- `SpawnManager` can be extended to support enemy unit spawning.
- Movement patterns can be extended (zigzag, formation, etc.) without modifying existing code.
