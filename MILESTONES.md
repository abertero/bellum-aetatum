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

---

## Milestone 3 — UnitStats Refactoring

### Objective

Improve the internal architecture by introducing a dedicated `UnitStats` class to encapsulate gameplay statistics. This refactoring separates data representation from raw JSON dictionaries, making the codebase more maintainable and type-safe.

### What Was Implemented

#### 1. UnitStats Class

- New `UnitStats` class (`scripts/unit_stats.gd`) that stores all gameplay statistics: `hp`, `attack`, `range`, `speed`, `cost`.
- Extends `RefCounted` as a pure data container.
- Constructor accepts all stat values with defaults.

#### 2. UnitStatsFactory

- New `UnitStatsFactory` class (`scripts/unit_stats_factory.gd`) responsible for converting JSON dictionaries into `UnitStats` instances.
- Single method: `create_from_dictionary(data: Dictionary) -> UnitStats`.
- Centralizes all stats deserialization logic in one place.

#### 3. DeckManager Integration

- `DeckManager` now uses `UnitStatsFactory` to convert the `stats` sub-dictionary into a `UnitStats` instance when loading the card database.
- The card dictionary now contains `stats` as a `UnitStats` object instead of a raw `Dictionary`.

#### 4. Unit Refactoring

- `Unit` now has a public property `stats: UnitStats` instead of reading from `_card_data["stats"]`.
- Movement reads `stats.speed` directly instead of extracting from dictionary.
- Removed `_extract_movement_data()` method (no longer needed).
- Removed `_speed` private variable (now accessed via `stats.speed`).

#### 5. BattleScene Update

- `BattleScene` now accesses `card_stats.cost` as a property instead of `stats.get("cost", 0)`.
- Type-safe access to stats throughout the UI code.

### Files Created

| File | Purpose |
|---|---|
| `scripts/unit_stats.gd` | Data class for unit statistics |
| `scripts/unit_stats_factory.gd` | Factory for deserializing JSON into UnitStats |

### Files Modified

| File | Changes | Reason |
|---|---|---|
| `autoload/deck_manager.gd` | +3 lines | Added `_stats_factory` instance, converts stats Dictionary to UnitStats during card loading |
| `scripts/unit.gd` | -5 lines | Removed `_speed` variable and `_extract_movement_data()`, added `stats: UnitStats` property |
| `scripts/battle_scene.gd` | ~2 lines | Changed from `stats.get("cost", 0)` to `card_stats.cost` |

### Architecture Improvements

#### Single Responsibility Principle

- **UnitStats**: Responsible only for storing gameplay statistics. No behavior, no parsing.
- **UnitStatsFactory**: Responsible only for deserializing JSON into UnitStats. No game logic.
- **Unit**: Owns a UnitStats instance, reads stats as properties instead of parsing dictionaries.
- **DeckManager**: Orchestrates the conversion during loading, keeping parsing logic centralized.

#### Open/Closed Principle

- Adding new stats (e.g., `crit_chance`, `armor`) only requires:
  1. Adding the field to `UnitStats`
  2. Adding the field to `UnitStatsFactory.create_from_dictionary()`
- No changes needed in Unit, BattleScene, or any consumer code.

#### Dependency Inversion

- `Unit` depends on `UnitStats` (abstraction) instead of raw `Dictionary` (concrete implementation).
- `DeckManager` depends on `UnitStatsFactory` (abstraction) instead of inline parsing logic.
- Consumers access stats as typed properties, not dictionary keys.

#### No Duplicated Parsing Logic

- Before: Multiple places could parse `stats` dictionary independently.
- After: Only `UnitStatsFactory` knows how to convert JSON to UnitStats.

### SOLID Compliance

| Principle | How |
|---|---|
| Single Responsibility | UnitStats stores data, Factory deserializes, Unit uses stats |
| Open/Closed | New stats added in one place (UnitStats + Factory) |
| Liskov Substitution | UnitStats can be extended or replaced without breaking Unit |
| Interface Segregation | UnitStats exposes only stat properties, no unnecessary methods |
| Dependency Inversion | Unit depends on UnitStats abstraction, not Dictionary implementation |

### Architecture Rules Applied

| Rule | How |
|---|---|
| Classes under 250 lines | `unit_stats.gd` is 19 lines, `unit_stats_factory.gd` is 13 lines |
| Functions under 30 lines | All functions are 1-10 lines |
| No static methods | Factory uses instance methods |
| Single responsibility per class | Each class has one clear purpose |
| Reusable scripts | UnitStats can be used anywhere stats are needed |
| No hardcoded game values | Stats still come from JSON |
| Factories over switches | UnitStatsFactory converts JSON to typed objects |
| Dependencies point inward | Unit -> UnitStats, DeckManager -> UnitStatsFactory |

### Behavior Preserved

- Units still move at the same speed.
- UI still displays the same cost values.
- Spawning still works identically.
- No visual or gameplay changes.

### Extension Points for Future Milestones

- `UnitStats` can be extended with new stats (crit, armor, abilities) without changing consumers.
- `UnitStats` can be made serializable for save/load systems.
- `UnitStats` can support stat modifiers (buffs/debuffs) in future combat milestones.
- `UnitStatsFactory` can be extended to load from different data sources (Resources, databases).

---

## Milestone 4 — Formation and Collision System

### Objective

Implement unit collision detection, formation mechanics, and a battle group system. Units now stop when they collide with enemies and form battle lines with configurable spacing.

### What Was Implemented

#### 1. Unit State Machine

- New `UnitState` class with enum: `MOVING`, `WAITING`, `BLOCKED`, `DEAD`.
- Units transition between states based on formation status.
- Visual debug label displays current state above each unit.

#### 2. Team System

- Units now have a `team` property ("player" or "enemy").
- SpawnManager accepts team parameter when creating units.
- FormationManager uses team to detect opposing units.

#### 3. BattleGroup Class

- Lightweight data structure that organizes units in combat.
- Tracks `frontline_position`, `allied_units`, and `enemy_units`.
- Does NOT calculate damage or resolve combat.

#### 4. FormationManager

- Dedicated system for collision detection and formation management.
- Detects when opposing units collide (within 40 pixels).
- Creates BattleGroups at collision points.
- Assigns units to groups and calculates formation positions.
- Configurable `formation_spacing` from stage JSON.

#### 5. Automatic Enemy Spawning

- BattleScene spawns enemy units every 3 seconds.
- Uses enemy deck from JSON.
- Cycles through enemy deck cards.

#### 6. Formation Behavior

- When two opposing units collide, they form a BattleGroup.
- Units change to `BLOCKED` state and stop moving.
- New allied units joining the formation are positioned behind the frontline.
- Units move to their formation position with `formation_spacing` offset.
- Units change to `WAITING` state while moving to formation, then `BLOCKED` when in position.

#### 7. Visual Debug

- Each unit displays its current state (Moving, Waiting, Blocked, Dead) above the sprite.
- State label is yellow for visibility.

### Files Created

| File | Lines | Purpose |
|---|---|---|
| `scripts/unit_state.gd` | 18 | Enum and state string conversion |
| `scripts/battle_group.gd` | 30 | Data structure for organizing units in combat |
| `scripts/formation_manager.gd` | 108 | Collision detection and formation management |

### Files Modified

| File | Changes | Reason |
|---|---|---|
| `data/stages/stage_001.json` | +1 field | Added `formation_spacing: 32` |
| `scripts/unit.gd` | +80 lines | Added state machine, team system, formation target, state label |
| `scripts/spawn_manager.gd` | +1 parameter | Added `team` parameter to spawn_unit |
| `scripts/battle_scene.gd` | +40 lines | Added FormationManager, enemy spawn timer, unit registration |

### Architecture Improvements

#### Single Responsibility Principle

- **UnitState**: Only defines states and converts to strings.
- **BattleGroup**: Only organizes units, no combat logic.
- **FormationManager**: Only handles collision detection and formation positioning.
- **Unit**: Owns state transitions and movement, delegates collision to FormationManager.
- **BattleScene**: Coordinates systems, doesn't calculate collisions.

#### Open/Closed Principle

- New unit states can be added to UnitState enum without modifying Unit.
- New formation patterns can be added to FormationManager without changing Unit.
- Formation spacing is configurable via JSON, not hardcoded.

#### Dependency Inversion

- Unit depends on UnitState abstraction, not concrete state logic.
- FormationManager depends on Unit interface (get_team, get_current_state), not implementation.
- BattleScene depends on FormationManager abstraction, not collision details.

### Formation Flow

```
BattleScene._physics_process()
  -> _update_enemy_spawn_timer()
       -> every 3 seconds: _spawn_enemy_unit()
            -> SpawnManager.spawn_unit(card, pos, target, parent, "enemy")
            -> FormationManager.register_unit(unit)

FormationManager._physics_process()
  -> _detect_collisions()
       -> for each pair of opposing units:
            -> if distance < 40px: _create_or_join_battle_group()
                 -> create BattleGroup at midpoint
                 -> add units to group
                 -> unit.set_battle_group(group) -> state = BLOCKED
                 -> _position_unit_in_formation() -> set formation target
  -> _update_formations()
       -> for each unit in groups:
            -> if MOVING: _position_unit_in_formation()

Unit._physics_process()
  -> match _current_state:
       -> MOVING: _move_toward(formation_target or target_position)
       -> WAITING: _move_toward(formation_target), then BLOCKED when arrived
       -> BLOCKED: do nothing
       -> DEAD: do nothing
```

### SOLID Compliance

| Principle | How |
|---|---|
| Single Responsibility | Each class has one clear purpose (state, group, formation, unit, scene) |
| Open/Closed | New states, formations, and teams can be added without modifying existing code |
| Liskov Substitution | Units can be replaced with different implementations without breaking FormationManager |
| Interface Segregation | Units expose only necessary methods (get_team, get_current_state, set_battle_group) |
| Dependency Inversion | BattleScene depends on FormationManager abstraction, not collision details |

### Architecture Rules Applied

| Rule | How |
|---|---|
| Classes under 250 lines | All new classes are under 110 lines |
| Functions under 30 lines | All functions are 1-15 lines |
| No static methods | Only UnitState.to_string() is static (pure utility) |
| Single responsibility per scene | Unit owns state, FormationManager owns collision, BattleScene owns coordination |
| Reusable scripts | BattleGroup and FormationManager work with any unit configuration |
| No hardcoded game values | Formation spacing comes from JSON |
| Factories over switches | FormationManager creates BattleGroups dynamically |
| Dependencies point inward | BattleScene -> FormationManager -> BattleGroup, Unit -> UnitState |

### What Was NOT Implemented (Intentionally)

- Combat / damage
- Attack mechanics
- Health reduction
- Target selection
- Abilities / effects
- Animations
- AOE / projectiles
- Spells
- Economy / deck editing

### Extension Points for Future Milestones

- `UnitState.DEAD` is reserved for future death mechanics.
- `BattleGroup` can be extended to calculate combat between allied and enemy units.
- `FormationManager` can support different formation types (line, column, wedge).
- `Unit` can support attack animations and combat states.
- `formation_spacing` can be made dynamic based on unit types.

---

## Milestone 5 — Battlefield Targeting & Formation

### Objective

Introduce battlefield targeting and ordered battle formations. Units now automatically acquire targets through a dedicated targeting system, and battle groups maintain deterministic formations where the next unit advances when the frontline dies.

### What Was Implemented

#### 1. TargetingSystem

- New dedicated system responsible for determining valid targets.
- Reads battle group formations and assigns targets to melee units.
- Emits `target_changed` through EventBus whenever a unit receives a different target.
- CombatSystem now reads `current_target` only — it never searches for targets.

#### 2. Ordered Battle Formations

- BattleGroup refactored to maintain two ordered formations: `player_formation` and `enemy_formation`.
- Formation order is deterministic and preserved.
- Exposes `get_frontline(team)` which returns the first alive unit in formation order.
- Exposes `get_next_target(unit)` which returns the opposing frontline.
- When a frontline unit dies, the next unit immediately becomes the new frontline.

#### 3. Unit Death & Frontline Advancement

- FormationSystem now handles unit death cleanup (moved from CombatSystem).
- When a unit dies, FormationSystem removes it from the battle group and emits `frontline_changed` if it was the frontline.
- TargetingSystem detects the change on the next frame and assigns the new frontline as target.

#### 4. Visual Debug Enhancements

- Each unit now displays three pieces of information above the sprite:
  - **Current Target** (cyan label)
  - **Current State** (yellow label)
  - **Current HP** (white label + health bar)
- Target display updates automatically when `current_target` changes.
- Extracted visual logic into `UnitVisualComponent` to maintain SRP and keep UnitInstance under 250 lines.

#### 5. Safe Target References

- `current_target` changed to `Variant` type to safely handle freed object references.
- Added `get_current_target()` method for safe typed access.
- `_validate_target()` clears freed references before they cause type errors.
- Prevents crashes when targets are destroyed between frames.

### Files Created

| File | Lines | Purpose |
|---|---|---|
| `systems/TargetingSystem.gd` | 35 | Assigns targets to melee units via BattleGroup; emits `target_changed` |
| `entities/UnitVisualComponent.gd` | 138 | Extracted visual building/updating from UnitInstance (SRP) |

### Files Modified

| File | Changes | Reason |
|---|---|---|
| `core/EventBus.gd` | +1 signal | Added `target_changed` signal for target updates |
| `entities/BattleGroup.gd` | Rewritten | Ordered formations, `get_frontline()`, `get_next_target()`, `get_all_units()` |
| `systems/CombatSystem.gd` | -26 lines | Reads only `current_target`; no longer searches for targets |
| `systems/FormationSystem.gd` | +14 lines | Uses new BattleGroup API; handles unit death + `frontline_changed` emission |
| `entities/UnitInstance.gd` | +8 lines | Delegates visuals to UnitVisualComponent; safe target validation |
| `scenes/battle_scene.gd` | +12 lines | Wires up TargetingSystem between FormationSystem and CombatSystem |

### Targeting Flow

```
FormationSystem detects collision -> creates BattleGroup with ordered formations
TargetingSystem reads formations -> assigns current_target -> emits target_changed
UnitInstance._validate_target() -> clears freed references
CombatSystem reads get_current_target() -> applies damage on timer
Unit dies -> FormationSystem removes from formation -> emits frontline_changed
TargetingSystem next frame -> assigns new frontline as target
```

### Architecture Improvements

#### Single Responsibility Principle

- **TargetingSystem**: Only responsible for target assignment. No damage calculation, no formation management.
- **CombatSystem**: Only applies damage based on `current_target`. Never searches for targets.
- **FormationSystem**: Manages formations and unit death cleanup. Emits `frontline_changed`.
- **BattleGroup**: Maintains ordered formations. Provides target lookup. Never calculates damage.
- **UnitVisualComponent**: Handles all visual building and updates. Separated from UnitInstance logic.

#### Open/Closed Principle

- New targeting rules can be added to TargetingSystem without modifying CombatSystem.
- New formation patterns can be added to BattleGroup without changing UnitInstance.
- Visual components can be extended without modifying core unit logic.

#### Dependency Inversion

- CombatSystem depends on `get_current_target()` abstraction, not on BattleGroup search logic.
- TargetingSystem depends on BattleGroup's `get_next_target()`, not on direct unit access.
- UnitInstance depends on UnitVisualComponent for visuals, not on inline visual code.

### SOLID Compliance

| Principle | How |
|---|---|
| Single Responsibility | Each system has one clear purpose (targeting, combat, formation, visuals) |
| Open/Closed | New targeting rules, formations, and visuals can be added without modifying existing code |
| Liskov Substitution | Units can be replaced with different implementations without breaking systems |
| Interface Segregation | Units expose only necessary methods (get_current_target, is_alive, is_melee) |
| Dependency Inversion | Systems depend on abstractions (get_current_target), not on concrete search logic |

### Architecture Rules Applied

| Rule | How |
|---|---|
| Classes under 250 lines | All classes under 205 lines after refactoring |
| Functions under 30 lines | All functions are 1-15 lines |
| No static methods | All methods are instance methods |
| Single responsibility per class | Each class has one clear purpose |
| Reusable scripts | TargetingSystem and UnitVisualComponent work with any unit configuration |
| No hardcoded game values | Targeting rules come from BattleGroup formation order |
| Composition over inheritance | UnitVisualComponent composed into UnitInstance |
| Dependencies point inward | CombatSystem -> TargetingSystem -> FormationSystem -> BattleGroup |

### What Was NOT Implemented (Intentionally)

- Ranged attacks
- Projectiles
- AOE mechanics
- Abilities / passives
- Status effects
- Legendary mechanics
- Economy / deck editing
- Victory conditions
- Audio / animations
- Menus / settings
- Save system
- Localization

### Extension Points for Future Milestones

- `TargetingSystem` can support ranged targeting rules (nearest, lowest HP, etc.).
- `BattleGroup` can support multiple formation types (line, column, wedge).
- `UnitInstance` can support target switching animations.
- `TargetingSystem` can support priority-based targeting for different unit types.
- `UnitVisualComponent` can support damage numbers, status icons, and attack indicators.
- `CombatSystem` can support different damage types and resistances.

---

## Milestone 6 — Attack Execution Architecture

### Objective

Introduce the attack execution architecture by extracting attack logic from CombatSystem into a dedicated AttackSystem with a polymorphic attack model abstraction and a registry for model resolution. Gameplay remains identical — only melee attacks continue working.

### What Was Implemented

#### 1. AttackSystem

- New dedicated system responsible for executing attacks.
- Receives attacker and target, returns a DamageResult.
- Delegates damage calculation to the appropriate AttackModel via AttackModelRegistry.
- Emits `attack_started` and `attack_finished` via EventBus.
- Stateless — implemented as RefCounted.
- Does NOT know concrete attack classes. Depends only on AttackModelRegistry.
- Does NOT search targets, spawn units, move units, or modify UI.

#### 2. Attack Model Abstraction

- New `AttackModel` base class (RefCounted) with virtual `execute(attacker, target) -> DamageResult`.
- New `MeleeAttackModel` extends AttackModel — calculates melee damage from `attacker.definition.attack`.
- Future attack models (ranged, AOE, etc.) can be added by extending AttackModel and registering in the registry.

#### 3. AttackModelRegistry

- New `AttackModelRegistry` class (RefCounted) responsible for registering and resolving attack models by string identifier.
- Provides `register(model_key, model)` and `resolve(model_key) -> AttackModel`.
- AttackSystem receives the registry through its constructor.
- Registration happens externally in BattleScene, not inside AttackSystem.

#### 4. DamageResult

- New lightweight data carrier (RefCounted).
- Fields: `damage`, `source`, `target`, `critical`, `blocked`.
- Only `damage` is used in this milestone. Other fields reserved for future milestones.

#### 5. UnitDefinition Extension

- Added `attack_model: String` field to UnitDefinition.
- Parsed from `stats.attack_model` in card JSON.
- Combat behavior now depends on this field instead of hardcoded range checks.

#### 6. CombatSystem Refactoring

- CombatSystem no longer performs attacks directly.
- Calls `AttackSystem.execute(attacker, target)` to obtain a DamageResult.
- Applies DamageResult via `target.take_damage(result.damage)`.
- CombatSystem remains the only system allowed to modify HP.

#### 7. UnitInstance Update

- `is_melee()` now checks `definition.attack_model == "melee"` instead of `definition.range <= 1`.
- No other changes to UnitInstance.

#### 8. EventBus Signals

- Added `attack_started(attacker, target)` signal.
- Added `attack_finished(attacker, target, result)` signal.

#### 9. Data Updates

- All cards in `cards.json` now include `attack_model` in their stats.
- Melee units (range 1): `"attack_model": "melee"`.
- Ranged units (range > 1): `"attack_model": "none"`.

### Files Created

| File | Lines | Purpose |
|---|---|---|
| `models/DamageResult.gd` | 8 | Lightweight damage result data carrier |
| `models/AttackModel.gd` | 6 | Base class for attack model abstraction |
| `models/MeleeAttackModel.gd` | 10 | Melee attack damage calculation |
| `models/AttackModelRegistry.gd` | 12 | Registers and resolves attack models by identifier |
| `systems/AttackSystem.gd` | 23 | Executes attacks via AttackModelRegistry, emits events |

### Files Modified

| File | Changes | Reason |
|---|---|---|
| `definitions/UnitDefinition.gd` | +2 lines | Added `attack_model` field and parsing |
| `entities/UnitInstance.gd` | ~1 line | `is_melee()` uses `attack_model` instead of range |
| `systems/CombatSystem.gd` | +5/-4 lines | Delegates to AttackSystem, applies DamageResult |
| `core/EventBus.gd` | +2 signals | Added `attack_started`, `attack_finished` |
| `scenes/battle_scene.gd` | +5 lines | Creates AttackModelRegistry, registers models, wires AttackSystem |
| `data/cards/cards.json` | +16 lines | Added `attack_model` to all card stats |

### Attack Flow

```
CombatSystem._update_attack_timer()
  -> timer expires
  -> AttackSystem.execute(attacker, target)
     -> EventBus.attack_started.emit(attacker, target)
     -> _resolve_damage(attacker, target)
        -> model_key = attacker.definition.attack_model ("melee")
        -> AttackModelRegistry.resolve(model_key) -> MeleeAttackModel
        -> MeleeAttackModel.execute(attacker, target)
           -> DamageResult { damage: attacker.definition.attack, source, target }
     -> EventBus.attack_finished.emit(attacker, target, result)
  -> CombatSystem._apply_damage_result(result)
     -> target.take_damage(result.damage)
```

### Architecture Improvements

#### Single Responsibility Principle

- **AttackSystem**: Only executes attacks and emits events. No timers, no target search, no HP modification. Does not know concrete attack classes.
- **AttackModelRegistry**: Only registers and resolves attack models. No attack logic.
- **AttackModel / MeleeAttackModel**: Only calculates damage values. No state, no side effects.
- **DamageResult**: Pure data carrier. No behavior.
- **CombatSystem**: Orchestrates combat timing and applies damage to HP. Delegates attack execution.
- **UnitDefinition**: Owns the `attack_model` field that determines combat behavior.

#### Open/Closed Principle

- New attack models (ranged, AOE, magic) can be added by:
  1. Creating a new class extending AttackModel
  2. Registering it in BattleScene via AttackModelRegistry
  3. Setting `attack_model` in card JSON
- No changes needed in AttackSystem, CombatSystem, UnitInstance, or any existing code.

#### Dependency Inversion

- CombatSystem depends on AttackSystem abstraction, not on damage calculation details.
- AttackSystem depends on AttackModelRegistry, not on concrete attack classes.
- AttackModelRegistry depends on AttackModel abstraction, not on concrete implementations.
- Adding new attack types requires no changes to consumers.

### SOLID Compliance

| Principle | How |
|---|---|
| Single Responsibility | AttackSystem executes, AttackModelRegistry resolves, AttackModel calculates, DamageResult carries data |
| Open/Closed | New attack models added by extending AttackModel and registering in registry |
| Liskov Substitution | Any AttackModel subclass can replace MeleeAttackModel |
| Interface Segregation | AttackModel exposes only `execute()`, DamageResult exposes only data fields |
| Dependency Inversion | CombatSystem -> AttackSystem -> AttackModelRegistry -> AttackModel abstraction chain |

### Architecture Rules Applied

| Rule | How |
|---|---|
| Classes under 250 lines | Largest new file is 23 lines (AttackSystem) |
| Functions under 30 lines | All functions are 1-7 lines |
| No static methods | All methods are instance methods |
| Composition over inheritance | AttackSystem composed with AttackModelRegistry; registry composed of AttackModel instances |
| No duplicated logic | Damage calculation lives only in MeleeAttackModel |
| Dependencies point inward | CombatSystem -> AttackSystem -> AttackModelRegistry -> AttackModel -> DamageResult |

### What Was NOT Implemented (Intentionally)

- Ranged attacks
- Projectiles
- AOE mechanics
- Abilities / passives
- Critical hits (field exists in DamageResult but unused)
- Healing
- Status effects
- Block mechanics (field exists in DamageResult but unused)
- Animations / particles
- Economy / deck editing
- Victory conditions
- Audio
- Menus / settings
- Save system
- Localization

### Extension Points for Future Milestones

- `AttackModel` can be extended with RangedAttackModel, AOEAttackModel, MagicAttackModel.
- `AttackModelRegistry` can register new models without modifying AttackSystem.
- `DamageResult.critical` can be used for critical hit mechanics.
- `DamageResult.blocked` can be used for block/dodge mechanics.
- `UnitDefinition.attack_model` can support any string value for new attack types.

---

## Milestone 6 — Spatial Query Architecture

### Objective

Introduce a reusable `SpatialQuerySystem` that becomes the single point for all battlefield queries. Decouple `TargetingSystem` and `CombatSystem` from direct `BattleGroup` and `FormationSystem` dependencies. Gameplay remains identical.

### What Was Implemented

#### 1. SpatialQuerySystem

- New dedicated system responsible for all battlefield queries.
- `RefCounted` — stateless query service, no `_physics_process`.
- Receives `FormationSystem` via `initialize()`.
- Internally uses `BattleGroup` but does not expose it in gameplay-facing API.
- Never modifies gameplay state, never moves units, never calculates combat.

#### 2. Supported Queries

| Method | Returns |
|---|---|
| `get_frontline(for_unit)` | Frontline unit opposing the given unit within its battle group. |
| `get_units_in_formation(owner)` | All alive units in formations for the given owner. |
| `get_units_by_owner(owner)` | All alive units belonging to the given owner. |
| `get_units_by_state(state)` | All alive units in the given state. |
| `get_closest_enemy(unit)` | Closest living enemy to the given unit. |
| `get_battle_group_count()` | Number of active battle groups (debug). |
| `get_units_in_group(index)` | Units in a specific battle group (debug). |
| `get_group_frontline(index, team)` | Frontline of a specific group (debug). |

#### 3. TargetingSystem Refactoring

- `TargetingSystem` now depends on `SpatialQuerySystem` instead of `FormationSystem`.
- No longer accesses `BattleGroup` directly.
- Uses `get_units_in_formation()` and `get_frontline()` for target assignment.
- Behavior is identical: same units receive the same targets.

#### 4. CombatSystem Refactoring

- `CombatSystem` no longer depends on `FormationSystem`.
- Tracks units via `EventBus` signals (`unit_spawned`, `unit_died`).
- Processes only units in battle groups (`unit.battle_group != null`).
- Behavior is identical: same units are attacked at the same timing.

#### 5. BattleGroup Cleanup

- `get_next_target()` removed — this was a gameplay rule embedded in a data structure.
- Equivalent logic moved to `SpatialQuerySystem.get_frontline()`.
- `BattleGroup` now exposes only low-level formation information.

#### 6. FormationSystem Extension

- Added `get_all_units()` public getter for `SpatialQuerySystem` to query all registered units.

#### 7. Debug Panel

- `BattleScene` creates a debug panel showing battle group count, units per group, and frontlines.
- Updates every frame via `_update_debug_panel()`.

### Files Created

| File | Lines | Purpose |
|---|---|---|
| `systems/SpatialQuerySystem.gd` | 85 | Battlefield query facade over FormationSystem/BattleGroup |

### Files Modified

| File | Changes | Reason |
|---|---|---|
| `entities/BattleGroup.gd` | -7 lines | Removed `get_next_target()` (gameplay rule moved to SpatialQuerySystem) |
| `systems/FormationSystem.gd` | +4 lines | Added `get_all_units()` public getter |
| `systems/TargetingSystem.gd` | Rewritten | Uses SpatialQuerySystem instead of FormationSystem/BattleGroup |
| `systems/CombatSystem.gd` | Rewritten | Uses EventBus tracking instead of FormationSystem/BattleGroup |
| `scenes/battle_scene.gd` | +30 lines | Wires SpatialQuerySystem, updates CombatSystem init, adds debug panel |

### Dependency Changes

```
Before:
  TargetingSystem -> FormationSystem -> BattleGroup
  CombatSystem    -> FormationSystem -> BattleGroup

After:
  TargetingSystem -> SpatialQuerySystem -> FormationSystem -> BattleGroup
  CombatSystem    -> EventBus (unit tracking)
```

### Behavior Verification

- TargetingSystem assigns identical targets: `get_frontline()` resolves through `unit.battle_group` to the same `get_frontline(team)` call.
- CombatSystem processes identical units: tracks all spawned units, filters by `battle_group != null` and `is_alive()`.
- Attack timing unchanged: same timer logic, same `AttackSystem.execute()` path.
- Formation positioning unchanged: FormationSystem logic untouched.
- Unit movement unchanged: UnitInstance logic untouched.

### SOLID Compliance

| Principle | How |
|---|---|
| Single Responsibility | SpatialQuerySystem only answers queries. BattleGroup only stores formation data. |
| Open/Closed | New queries added to SpatialQuerySystem without modifying callers. |
| Liskov Substitution | SpatialQuerySystem can be replaced with a different implementation. |
| Interface Segregation | Callers depend only on query methods they use. |
| Dependency Inversion | TargetingSystem depends on SpatialQuerySystem abstraction, not BattleGroup internals. |

### Architecture Rules Applied

| Rule | How |
|---|---|
| Classes under 250 lines | SpatialQuerySystem is 85 lines |
| Functions under 30 lines | All functions are 1-12 lines |
| Composition over inheritance | SpatialQuerySystem composed with FormationSystem reference |
| No duplicated queries | All queries centralized in SpatialQuerySystem |
| Dependencies point inward | TargetingSystem -> SpatialQuerySystem -> FormationSystem -> BattleGroup |

### What Was NOT Implemented (Intentionally)

- Ranged attacks
- Projectiles
- AOE mechanics
- Abilities / passives
- Status effects
- Economy / deck editing
- Victory conditions
- Audio / animations
- Menus / settings
- Save system

### Extension Points for Future Milestones

- `SpatialQuerySystem` can add range-based queries for ranged targeting.
- `SpatialQuerySystem` can add area queries for AOE mechanics.
- `SpatialQuerySystem` can add priority-based queries for ability targeting.
- New queries can be added without modifying existing methods or callers.
- `BattleGroup` internal implementation can be replaced without API changes.

---

## Milestone 8 — Action Framework

### Objective

Introduce a generic Action Framework that represents the outcome of gameplay operations as first-class objects. The attack pipeline now produces `DamageAction` instead of `DamageResult`. `CombatSystem` consumes `DamageAction` and broadcasts it through `EventBus`. Gameplay remains identical.

### What Was Implemented

#### 1. GameAction Base Class

- New `GameAction` class (`actions/GameAction.gd`), extends `RefCounted`.
- Common contract for all actions: `action_id`, `timestamp`, `source`, `target`, `metadata`.
- `action_id` uses a static sequential counter for unique identification.
- `timestamp` records creation time via `Time.get_ticks_msec()`.
- `metadata` is a `Dictionary` for extensible data.
- Actions are immutable after creation by convention.

#### 2. DamageAction

- New `DamageAction` class (`actions/DamageAction.gd`), extends `GameAction`.
- Fields: `damage`, `critical`, `blocked`.
- Created via static factory method `DamageAction.create(damage, source, target, critical, blocked, metadata)`.
- Replaces `DamageResult` entirely — no duplicated result structures.

#### 3. Attack Pipeline Update

- `AttackModel.execute()` now returns `DamageAction` instead of `DamageResult`.
- `MeleeAttackModel.execute()` creates `DamageAction` via factory method.
- `AttackSystem.execute()` returns `DamageAction`.
- `CombatSystem._apply_damage_action()` consumes `DamageAction`, applies HP, broadcasts via `EventBus.action_performed`.

#### 4. EventBus Update

- `attack_finished` now carries a `GameAction` instead of separate attacker/target/result parameters.
- `action_performed(action: GameAction)` is a new generic signal for broadcasting any action.
- `unit_damaged(unit, damage)` is removed. `action_performed` replaces it with a rich object.

#### 5. UnitInstance Update

- `take_damage()` no longer emits `unit_damaged`. The `action_performed` signal covers this use case with a `GameAction` object.
- `unit_died` emission is unchanged.

#### 6. DamageResult Removal

- `models/DamageResult.gd` and its `.uid` file are removed.
- `DamageAction` is the single damage outcome type.

### Files Created

| File | Lines | Purpose |
|---|---|---|
| `actions/GameAction.gd` | 17 | Base class for all gameplay actions |
| `actions/DamageAction.gd` | 13 | Damage action with factory method |

### Files Modified

| File | Changes | Reason |
|---|---|---|
| `models/AttackModel.gd` | Return type changed | Returns `DamageAction` instead of `DamageResult` |
| `models/MeleeAttackModel.gd` | Return type and creation changed | Creates `DamageAction` via factory |
| `systems/AttackSystem.gd` | Return type changed | Returns `DamageAction` instead of `DamageResult` |
| `systems/CombatSystem.gd` | Method renamed and updated | `_apply_damage_action` consumes `DamageAction`, emits `action_performed` |
| `core/EventBus.gd` | Signals updated | `attack_finished` carries `GameAction`, `action_performed` added, `unit_damaged` removed |
| `entities/UnitInstance.gd` | -1 line | Removed `unit_damaged` emission from `take_damage()` |

### Files Deleted

| File | Reason |
|---|---|
| `models/DamageResult.gd` | Replaced by `DamageAction` |
| `models/DamageResult.gd.uid` | Associated UID file |

### Attack Flow

```
CombatSystem._update_attack_timer()
  -> timer expires
  -> AttackSystem.execute(attacker, target)
     -> EventBus.attack_started.emit(attacker, target)
     -> _resolve_damage(attacker, target)
        -> AttackModelRegistry.resolve(model_key)
        -> MeleeAttackModel.execute(attacker, target)
           -> DamageAction.create(attack, attacker, target)
     -> EventBus.attack_finished.emit(action)
  -> CombatSystem._apply_damage_action(action)
     -> target.take_damage(action.damage)
        -> if not alive: EventBus.unit_died.emit(target)
     -> EventBus.action_performed.emit(action)
```

### Architecture Improvements

#### Single Responsibility Principle

- **GameAction**: Only defines the action contract. No behavior, no state mutation.
- **DamageAction**: Only carries damage-specific data. Created via factory, not modified afterward.
- **CombatSystem**: Consumes actions and applies HP. Does not create actions.
- **AttackSystem**: Produces actions. Does not apply them.

#### Open/Closed Principle

- New action types (HealAction, SpawnAction, etc.) extend `GameAction` without modifying existing code.
- `action_performed` signal handles any `GameAction` subtype. No new signals needed per action type.

#### Dependency Inversion

- Systems depend on `GameAction` abstraction, not on concrete damage types.
- EventBus broadcasts `GameAction`, not primitive values.

### SOLID Compliance

| Principle | How |
|---|---|
| Single Responsibility | GameAction defines contract, DamageAction carries damage data, CombatSystem applies, AttackSystem produces |
| Open/Closed | New action types extend GameAction without modifying existing code |
| Liskov Substitution | Any GameAction subclass can be broadcast through action_performed |
| Interface Segregation | Actions expose only data fields, no unnecessary methods |
| Dependency Inversion | Systems depend on GameAction abstraction, not concrete implementations |

### Architecture Rules Applied

| Rule | How |
|---|---|
| Classes under 250 lines | GameAction is 17 lines, DamageAction is 13 lines |
| Functions under 30 lines | All functions are 1-6 lines |
| Composition over inheritance | DamageAction extends GameAction with additional fields |
| No duplicated result structures | DamageResult removed, DamageAction is the single damage outcome type |
| Dependencies point inward | CombatSystem -> DamageAction -> GameAction |

### Behavior Verification

- Damage calculation unchanged: `MeleeAttackModel` still reads `attacker.definition.attack`.
- HP application unchanged: `CombatSystem` still calls `target.take_damage(action.damage)`.
- Attack timing unchanged: same timer logic, same `AttackSystem.execute()` path.
- Unit death unchanged: `UnitInstance.take_damage()` still emits `unit_died` when HP reaches 0.
- Formation unchanged: `FormationSystem` still handles death cleanup.
- Targeting unchanged: `TargetingSystem` still assigns frontlines.

### What Was NOT Implemented (Intentionally)

- HealAction
- SpawnAction
- ProjectileAction
- StatusEffectAction
- AbilityAction
- EconomyAction
- Ranged attacks
- Projectiles
- AOE mechanics
- Animations / particles
- Victory conditions
- Audio
- Menus / settings
- Save system

### Extension Points for Future Milestones

- `GameAction` can be extended with HealAction, SpawnAction, ProjectileAction, StatusEffectAction, AbilityAction, EconomyAction.
- `action_performed` signal handles any action type uniformly.
- `metadata` dictionary allows per-action extensible data without modifying the base class.
- Action logging, replay, and analytics can consume `GameAction` objects uniformly.
- Virtual methods (e.g., `apply()`, `revert()`) can be added to `GameAction` when behavior is needed.

---

## Milestone 8 — Command Framework

### Objective

Introduce a Command Framework that separates player intent from gameplay execution. Commands represent immutable requests that flow through a CommandDispatcher to the appropriate systems. This decouples input sources (player UI, AI, replay) from system implementations and provides a foundation for future features like replay, AI integration, and network play.

### What Was Implemented

#### 1. GameCommand Base Class

- New `GameCommand` class (`commands/GameCommand.gd`), extends `RefCounted`.
- Common contract for all commands: `command_id`, `timestamp`, `metadata`.
- `command_id` uses a static sequential counter for unique identification.
- `timestamp` records creation time via `Time.get_ticks_msec()`.
- `metadata` is a `Dictionary` for extensible data.
- Commands are immutable after creation by convention.

#### 2. PlayCardCommand

- New `PlayCardCommand` class (`commands/PlayCardCommand.gd`), extends `GameCommand`.
- Fields: `card_definition`, `spawn_position`, `target_position`, `parent`, `team`.
- Created via static factory method `PlayCardCommand.create()`.
- Represents player or AI intent to spawn a unit.

#### 3. AttackCommand

- New `AttackCommand` class (`commands/AttackCommand.gd`), extends `GameCommand`.
- Fields: `attacker`, `target`.
- Created via static factory method `AttackCommand.create()`.
- Represents intent to execute an attack.

#### 4. CommandDispatcher

- New `CommandDispatcher` class (`commands/CommandDispatcher.gd`), extends `RefCounted`.
- Routes commands to responsible systems.
- Never implements gameplay logic.
- Methods:
  - `initialize(spawn_system, attack_system)`: Dependency injection.
  - `dispatch(command) -> Variant`: Routes to appropriate system.
  - `_dispatch_play_card(command) -> UnitInstance`: Calls SpawnSystem.
  - `_dispatch_attack(command) -> DamageAction`: Calls AttackSystem.

#### 5. BattleScene Integration

- BattleScene now creates `PlayCardCommand` when player clicks card button.
- Enemy spawn timer also creates `PlayCardCommand` for AI spawns.
- Commands dispatched through `CommandDispatcher` instead of calling `SpawnSystem` directly.
- BattleScene initializes `CommandDispatcher` with references to `SpawnSystem` and `AttackSystem`.

#### 6. CombatSystem Integration

- CombatSystem now creates `AttackCommand` when attack timer expires.
- Commands dispatched through `CommandDispatcher` instead of calling `AttackSystem` directly.
- CombatSystem receives `DamageAction` from dispatcher and applies it.

### Files Created

| File | Lines | Purpose |
|---|---|---|
| `commands/GameCommand.gd` | 15 | Base class for all commands |
| `commands/PlayCardCommand.gd` | 25 | Command to spawn a unit |
| `commands/AttackCommand.gd` | 12 | Command to execute an attack |
| `commands/CommandDispatcher.gd` | 33 | Routes commands to systems |

### Files Modified

| File | Changes | Reason |
|---|---|---|
| `scenes/battle_scene.gd` | +15 lines | Creates PlayCardCommand, initializes CommandDispatcher |
| `systems/CombatSystem.gd` | +3/-2 lines | Creates AttackCommand, dispatches via CommandDispatcher |

### Command Flow

```
Player Input / AI / Replay
  ↓
PlayCardCommand / AttackCommand (immutable request)
  ↓
CommandDispatcher (routing only)
  ↓
SpawnSystem / AttackSystem (execution)
  ↓
UnitInstance / DamageAction (result)
  ↓
EventBus (broadcast)
```

### Architecture Improvements

#### Single Responsibility Principle

- **GameCommand**: Only defines the command contract. No behavior, no state mutation.
- **PlayCardCommand**: Only carries spawn request data. Created via factory, not modified afterward.
- **AttackCommand**: Only carries attack request data. Created via factory, not modified afterward.
- **CommandDispatcher**: Only routes commands. Never implements gameplay logic.
- **Systems**: Only execute commands and produce actions.

#### Open/Closed Principle

- New command types (MoveCommand, UseAbilityCommand, etc.) extend `GameCommand` without modifying existing code.
- CommandDispatcher can be extended to route new command types without modifying systems.
- Input sources (UI, AI, replay) can create commands without knowing system internals.

#### Dependency Inversion

- Input sources depend on `GameCommand` abstraction, not on concrete systems.
- CommandDispatcher depends on `GameCommand` and system abstractions.
- Systems don't know about commands (they keep their existing API).

### SOLID Compliance

| Principle | How |
|---|---|
| Single Responsibility | GameCommand defines contract, PlayCardCommand/AttackCommand carry data, CommandDispatcher routes, Systems execute |
| Open/Closed | New command types extend GameCommand without modifying existing code |
| Liskov Substitution | Any GameCommand subclass can be dispatched through CommandDispatcher |
| Interface Segregation | Commands expose only data fields, no unnecessary methods |
| Dependency Inversion | Input sources depend on GameCommand abstraction, not concrete systems |

### Architecture Rules Applied

| Rule | How |
|---|---|
| Classes under 250 lines | GameCommand is 15 lines, PlayCardCommand is 25 lines, AttackCommand is 12 lines, CommandDispatcher is 33 lines |
| Functions under 30 lines | All functions are 1-8 lines |
| Composition over inheritance | Commands extend GameCommand with additional fields |
| No duplicated logic | CommandDispatcher centralizes routing logic |
| Dependencies point inward | Input -> Commands -> Systems -> Actions |

### Behavior Verification

- Unit spawning unchanged: Same positions, same timing, same unit creation.
- Combat unchanged: Same damage calculation, same attack speed, same HP application.
- Formation unchanged: Same collision detection, same positioning.
- Targeting unchanged: Same frontline selection.
- Death unchanged: Same cleanup and removal.

Only the request path changed:
- Before: `BattleScene → SpawnSystem`
- After: `BattleScene → PlayCardCommand → CommandDispatcher → SpawnSystem`

- Before: `CombatSystem → AttackSystem`
- After: `CombatSystem → AttackCommand → CommandDispatcher → AttackSystem`

End result is identical.

### What Was NOT Implemented (Intentionally)

- Command validation
- Command queuing
- Command logging
- Replay system
- AI integration
- Network play
- MoveCommand
- UseAbilityCommand
- SpawnCommand (generic spawn)
- EconomyCommand
- EndTurnCommand
- Ranged attacks
- Projectiles
- AOE mechanics
- Animations / particles
- Victory conditions
- Audio
- Menus / settings
- Save system

### Extension Points for Future Milestones

- `GameCommand` can be extended with MoveCommand, UseAbilityCommand, SpawnCommand, EconomyCommand, EndTurnCommand.
- CommandDispatcher can route new command types without modifying systems.
- Command validation can be added to CommandDispatcher before routing.
- Command logging can track all commands for debugging and analytics.
- Replay system can serialize commands and replay them in sequence.
- AI can generate commands using the same interface as player input.
- Network play can send commands over the network for multiplayer.
- Tutorial system can inject commands to guide players.


