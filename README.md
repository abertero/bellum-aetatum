# Bellum Aetatum

A strategy game inspired by Battle Cats, auto battlers, and collectible card games.

Players build a deck before entering battle. Units are represented by cards. The battlefield contains two bases. Players summon units from their deck.

## Vision

Everything in the game should be configurable without changing source code. The engine interprets data instead of hardcoding it.

## Tech Stack

- **Engine:** Godot 4.4
- **Language:** GDScript (typed)
- **Data Format:** JSON

## Folder Structure

```
res://
    scenes/              # Scene files (.tscn) and scene scripts
    core/                # Autoload singletons and core utilities
    entities/            # Game entities (UnitInstance, BattleGroup, UnitVisualComponent)
    commands/            # Command framework (GameCommand, PlayCardCommand, AttackCommand, CommandDispatcher)
    systems/             # Game systems (CombatSystem, FormationSystem, SpatialQuerySystem, TargetingSystem, SpawnSystem, DeckSystem, AttackSystem)
    actions/             # Action framework (GameAction, DamageAction)
    models/              # Attack models and registry (AttackModel, MeleeAttackModel, AttackModelRegistry)
    definitions/         # Data definitions (UnitDefinition, StageDefinition, DeckDefinition)
    factories/           # Object factories (UnitFactory)
    data/
        cards/           # Card database (cards.json)
        decks/           # Deck definitions (player_deck.json, enemy_deck.json)
        stages/          # Stage configurations (stage_001.json)
    assets/
        cards/           # Card artwork (future)
    docs/
        adr/             # Architecture Decision Records
```

## Architectural Layers

The architecture follows a layered design with strict dependency direction: outer layers depend on inner layers, never the reverse.

```
scenes/ -> commands/ -> systems/ -> actions/ -> models/ -> definitions/
                        -> actions -> models
                        -> entities/ -> definitions/
                        -> core/
```

### Core

Autoloaded singletons available globally.

| Class | Responsibility |
|---|---|
| `JsonLoader` | Reads and parses JSON files. No game logic. |
| `DeckSystem` | Loads card database and builds decks from JSON. |
| `EventBus` | Global signal bus for decoupled communication between systems. |
| `UnitState` | Enum and string conversion for unit states. |

### Commands

Command framework separating player intent from gameplay execution. Commands are immutable requests that never modify game state.

| Class | Type | Responsibility |
|---|---|---|
| `GameCommand` | RefCounted | Base class for all commands. Contains command_id, timestamp, metadata. Immutable after creation. |
| `PlayCardCommand` | RefCounted | Extends GameCommand. Represents player intent to spawn a unit. Carries card definition, positions, and team. |
| `AttackCommand` | RefCounted | Extends GameCommand. Represents intent to attack. Carries attacker and target references. |
| `CommandDispatcher` | RefCounted | Routes commands to responsible systems. Never implements gameplay logic. |

### Systems

Game logic systems that orchestrate behavior.

| Class | Type | Responsibility |
|---|---|---|
| `SpawnSystem` | RefCounted | Instantiates UnitInstance scenes via UnitFactory. |
| `FormationSystem` | Node | Detects collisions, manages battle groups and formations. |
| `SpatialQuerySystem` | RefCounted | Provides battlefield queries (frontline, units by owner/state, closest enemy). Read-only. |
| `TargetingSystem` | Node | Assigns targets to melee units via SpatialQuerySystem. |
| `AttackSystem` | RefCounted | Executes attacks via AttackModelRegistry. Produces DamageAction. Emits attack events. |
| `CombatSystem` | Node | Orchestrates combat timing, dispatches AttackCommand, consumes DamageAction, applies HP. Tracks units via EventBus. |
| `DeckSystem` | Node (autoload) | Loads card database and resolves deck lists. |

### Models

Attack model abstraction and registry.

| Class | Type | Responsibility |
|---|---|---|
| `AttackModel` | RefCounted | Abstract base class defining the attack execution contract. Returns `DamageAction`. |
| `MeleeAttackModel` | RefCounted | Calculates melee damage from attacker definition. Produces `DamageAction`. |
| `AttackModelRegistry` | RefCounted | Registers and resolves attack models by identifier. |

### Actions

Generic action framework representing gameplay operation outcomes.

| Class | Type | Responsibility |
|---|---|---|
| `GameAction` | RefCounted | Base class for all actions. Contains action_id, timestamp, source, target, metadata. Immutable after creation. |
| `DamageAction` | RefCounted | Extends GameAction with damage, critical, blocked. Created via static factory method. |

### Entities

Runtime game objects.

| Class | Type | Responsibility |
|---|---|---|
| `UnitInstance` | Node2D | Represents one spawned unit on the battlefield. Owns state, movement, and HP. |
| `BattleGroup` | RefCounted | Maintains ordered player/enemy formations. Provides frontline lookup. |
| `UnitVisualComponent` | Node | Handles visual building and updates (HP bar, labels, target display). |

### Definitions

Pure data containers parsed from JSON.

| Class | Type | Responsibility |
|---|---|---|
| `UnitDefinition` | RefCounted | Stores unit data (hp, attack, range, speed, cost, attack_model). |
| `StageDefinition` | RefCounted | Stores stage configuration (battlefield, spawn positions, formation spacing). |
| `DeckDefinition` | RefCounted | Stores deck card IDs. |

### Factories

Object creation.

| Class | Type | Responsibility |
|---|---|---|
| `UnitFactory` | RefCounted | Creates UnitInstance from PackedScene and initializes with definition. |

## EventBus

All systems communicate through `EventBus` signals, avoiding direct coupling.

| Signal | Emitter | Listeners |
|---|---|---|
| `battle_started` | BattleScene | (future) |
| `battle_ended` | (future) | (future) |
| `unit_spawned(unit)` | SpawnSystem | FormationSystem, CombatSystem |
| `unit_moved(unit)` | (future) | (future) |
| `unit_died(unit)` | UnitInstance | FormationSystem, CombatSystem |
| `frontline_changed(group)` | FormationSystem | (future) |
| `target_changed(unit, target)` | TargetingSystem | (future) |
| `attack_started(attacker, target)` | AttackSystem | (future) |
| `attack_finished(action)` | AttackSystem | (future) |
| `action_performed(action)` | CombatSystem | (future) |

## Gameplay Flow

```
BattleScene._ready()
  -> Load stage from JSON
  -> Setup systems (SpawnSystem, FormationSystem, SpatialQuerySystem, TargetingSystem, AttackSystem, CombatSystem)
  -> Setup CommandDispatcher
  -> Load decks from JSON
  -> Create card button UI

Player clicks card button
  -> PlayCardCommand.create()
  -> CommandDispatcher.dispatch(command)
     -> SpawnSystem.spawn_unit()
        -> UnitFactory.create_unit()
        -> UnitInstance.configure_movement()
        -> EventBus.unit_spawned emitted

FormationSystem._physics_process()
  -> Detect collisions between opposing units
  -> Create BattleGroup at collision point
  -> Position units in formation

TargetingSystem._physics_process()
  -> SpatialQuerySystem.get_units_in_formation() for each team
  -> SpatialQuerySystem.get_frontline() for each melee unit
  -> Assign frontline as target
  -> EventBus.target_changed emitted

CombatSystem._physics_process()
  -> Track units via EventBus (unit_spawned, unit_died)
  -> Check attack timers for units with valid targets
  -> AttackCommand.create(attacker, target)
  -> CommandDispatcher.dispatch(command)
     -> AttackSystem.execute(attacker, target)
        -> AttackModelRegistry.resolve(attack_model)
        -> MeleeAttackModel.execute() -> DamageAction
        -> EventBus.attack_started / attack_finished emitted
  -> Consume DamageAction via target.take_damage()
  -> EventBus.action_performed emitted with DamageAction

Unit dies
  -> EventBus.unit_died emitted
  -> FormationSystem removes from formation
  -> CombatSystem removes from tracked units
  -> TargetingSystem assigns new frontline next frame
```

## Milestones

### Completed

- [x] **Milestone 1** - Architecture validation: data-driven loading, unit spawning, stage configuration
- [x] **Milestone 2** - Unit movement: automatic movement from base to base, framerate independent
- [x] **Milestone 3** - UnitStats refactoring: dedicated stats class, centralized parsing
- [x] **Milestone 4** - Formation and collision: unit collision detection, battle groups, formation positioning
- [x] **Milestone 5** - Battlefield targeting: TargetingSystem, ordered formations, frontline advancement
- [x] **Milestone 5.5** - Attack execution architecture: AttackSystem, AttackModel abstraction, AttackModelRegistry
- [x] **Milestone 6** - Spatial query architecture: SpatialQuerySystem, decoupled targeting, EventBus-based combat tracking
- [x] **Milestone 7** - Action Framework: GameAction base class, DamageAction, action pipeline, EventBus action broadcast
- [x] **Milestone 8** - Command Framework: GameCommand base class, PlayCardCommand, AttackCommand, CommandDispatcher

### Planned

- [ ] **Milestone 9** - Ranged attacks: RangedAttackModel, range-based targeting
- [ ] **Milestone 10** - Projectiles: projectile entities, travel time, visual feedback
- [ ] **Milestone 11** - Abilities and passives: ability system, trigger conditions
- [ ] **Milestone 12** - Status effects: buffs, debuffs, duration, stacking
- [ ] **Milestone 13** - Victory conditions: base destruction, win/lose detection
- [ ] **Milestone 14** - Economy: gold, card costs, deck building
- [ ] **Milestone 15** - Animations and visual effects
- [ ] **Milestone 16** - Audio: sound effects, music
- [ ] **Milestone 17** - Menus, settings, save system

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

- **Single Responsibility:** Each class has one reason to change.
- **Open/Closed:** New cards via JSON. New attack models via AttackModel + registry.
- **Liskov Substitution:** Any AttackModel subclass can replace MeleeAttackModel.
- **Interface Segregation:** Classes depend only on the data they consume.
- **Dependency Inversion:** Systems depend on abstractions, not concrete implementations.

## Running the Project

1. Open Godot 4.4.
2. Import the project from this directory.
3. Run the main scene (`scenes/battle_scene.tscn`).
