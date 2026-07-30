# Bellum Aetatum

A strategy game inspired by Battle Cats, auto battlers, and collectible card games.

Players build a deck before entering battle. Units are represented by cards. The battlefield contains two bases. Players summon units from their deck.

## Vision

Everything in the game should be configurable without changing source code. The engine interprets data instead of hardcoding it.

## Tech Stack

- **Engine:** Godot 4.4
- **Language:** GDScript (typed)
- **Data Format:** JSON

## Project Structure

```
res://
    scenes/              # Scene files (.tscn)
    core/                # Core systems (EventBus, UnitState, JsonLoader)
    entities/            # Game entities (UnitInstance, BattleGroup, UnitVisualComponent)
    systems/             # Game systems (CombatSystem, FormationSystem, TargetingSystem, SpawnSystem, DeckSystem, AttackSystem)
    models/              # Attack models (AttackModel, MeleeAttackModel, DamageResult)
    definitions/         # Data definitions (UnitDefinition, StageDefinition, DeckDefinition)
    factories/           # Object factories (UnitFactory)
    data/
        cards/           # Card database (cards.json)
        decks/           # Deck definitions (player_deck.json, enemy_deck.json)
        stages/          # Stage configurations (stage_001.json)
    assets/
        cards/           # Card artwork (future)
```

## Architecture

### Core Systems (Autoload)

| Class | Responsibility |
|---|---|
| `JsonLoader` | Reads and parses JSON files |
| `DeckSystem` | Loads card database and builds decks |
| `EventBus` | Global signal bus for decoupled communication |

### Game Systems

| Class | Type | Responsibility |
|---|---|---|
| `SpawnSystem` | RefCounted | Instantiates UnitInstance scenes from card data |
| `FormationSystem` | Node | Detects collisions, manages battle groups and formations |
| `TargetingSystem` | Node | Assigns targets to melee units via battle groups |
| `AttackSystem` | RefCounted | Executes attacks via AttackModel, emits attack events |
| `CombatSystem` | Node | Orchestrates combat timing, delegates to AttackSystem, applies DamageResult |

### Attack Models

| Class | Type | Responsibility |
|---|---|---|
| `AttackModel` | RefCounted | Base class for attack model abstraction |
| `MeleeAttackModel` | RefCounted | Calculates melee damage from attacker definition |
| `DamageResult` | RefCounted | Data carrier for attack results (damage, source, target, critical, blocked) |

### Entities

| Class | Type | Responsibility |
|---|---|---|
| `UnitInstance` | Node2D | Represents one spawned unit on the battlefield |
| `BattleGroup` | RefCounted | Maintains ordered player/enemy formations |
| `UnitVisualComponent` | Node | Handles visual building and updates (HP bar, labels) |

### Data Definitions

| Class | Type | Responsibility |
|---|---|---|
| `UnitDefinition` | RefCounted | Stores unit data (hp, attack, range, speed, cost, attack_model) |
| `StageDefinition` | RefCounted | Stores stage configuration (battlefield, spawn positions) |
| `DeckDefinition` | RefCounted | Stores deck card IDs |

### Communication Flow

```
BattleScene
  -> JsonLoader (reads JSON)
  -> DeckSystem (loads decks via JsonLoader)
  -> SpawnSystem (spawns units via UnitFactory)
  -> FormationSystem (detects collisions, manages formations)
  -> TargetingSystem (assigns targets from formations)
  -> CombatSystem (orchestrates timing, delegates to AttackSystem)
  -> AttackSystem (executes attacks via AttackModel, emits events)
  -> UnitInstance (displays visuals via UnitVisualComponent)

EventBus (decoupled communication)
  - unit_spawned
  - unit_damaged
  - unit_died
  - frontline_changed
  - target_changed
  - attack_started
  - attack_finished
```

## Architecture Rules

- Every class should remain under 250 lines.
- Every function should remain under 30 lines.
- Avoid static methods unless they are pure utility functions.
- Prefer signals over tight coupling.
- Every scene should have a single responsibility.
- Every script should be reusable.
- Never duplicate JSON parsing logic.
- Never hardcode game values.
- Prefer factories instead of switch statements.
- Keep dependencies pointing inward.

## SOLID Principles

- **Single Responsibility:** Each class has one reason to change. JsonLoader only reads files. DeckSystem only resolves decks. TargetingSystem only assigns targets. AttackSystem only executes attacks. CombatSystem orchestrates timing and applies damage.
- **Open/Closed:** New cards are added via JSON, not code. New stages require only a new JSON file. New targeting rules can be added to TargetingSystem without modifying CombatSystem. New attack models extend AttackModel without modifying existing systems.
- **Liskov Substitution:** UnitInstance can be extended without breaking the SpawnSystem contract. BattleGroup can be extended without breaking FormationSystem. Any AttackModel subclass can replace MeleeAttackModel.
- **Interface Segregation:** Classes depend only on the data they consume. CombatSystem only reads DamageResult. TargetingSystem only reads formation order.
- **Dependency Inversion:** BattleScene depends on abstractions (JsonLoader, DeckSystem, SpawnSystem, FormationSystem, TargetingSystem, AttackSystem, CombatSystem), not on concrete data or scenes.

## Running the Project

1. Open Godot 4.4.
2. Import the project from this directory.
3. Run the main scene (`scenes/battle_scene.tscn`).

## Milestones

See `MILESTONES.md` for detailed documentation of each milestone.

- [x] Milestone 1 — Architecture validation
- [x] Milestone 2 — Unit movement
- [x] Milestone 3 — UnitStats refactoring
- [x] Milestone 4 — Formation and collision system
- [x] Milestone 5 — Battlefield targeting & formation
- [x] Milestone 6 — Attack execution architecture
