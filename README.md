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
    core/                # Autoload singletons and core utilities (EventBus, JsonLoader, UnitState, SimulationContext, MatchState)
    entities/            # Game entities (UnitInstance, BattleGroup, UnitVisualComponent, ProjectileInstance, NexusState)
    commands/            # Command framework (GameCommand, PlayCardCommand, AttackCommand, CommandDispatcher)
    systems/             # Game systems (CombatSystem, FormationSystem, SpatialQuerySystem, TargetingSystem, SpawnSystem, DeckSystem, AttackSystem, EconomySystem, ProjectileSystem, CollisionSystem, AffinityRegistry, AffinityRuleSystem, EffectRegistry, EffectLoader, EffectSystem, AbilityRegistry, AbilityLoader, AbilitySystem, MatchFlowSystem, NexusSystem)
    actions/             # Action framework (GameAction, DamageAction)
    resources/           # Resource runtime state (ResourceInstance)
    models/              # Attack models and registry (AttackModel, MeleeAttackModel, RangedAttackModel, AttackModelRegistry, ProjectileDefinitionRegistry, CombatModifier, CombatModifierCollection)
    definitions/         # Data definitions (UnitDefinition, StageDefinition, DeckDefinition, ResourceDefinition, ProjectileDefinition, AffinityDefinition, EffectDefinition, AbilityDefinition, MatchRulesDefinition)
    factories/           # Object factories (UnitFactory, ProjectileFactory)
    effects/             # Effect runtime (EffectInstance, EffectComponent, DurationComponent, CombatModifierComponent)
    abilities/           # Ability runtime (AbilityInstance, AbilityComponent, ApplyEffectComponent, SpawnProjectileComponent, GenerateCommandComponent)
    pipelines/           # Ability pipeline (AbilityPipeline, AbilityPipelineNode, AbilityPipelineExecutor)
    conditions/          # Match conditions (MatchCondition, DestroyEnemyNexusCondition, DestroyPlayerNexusCondition, TimeLimitCondition)
    data/
        cards/           # Card database (cards.json)
        decks/           # Deck definitions (player_deck.json, enemy_deck.json)
        stages/          # Stage configurations (stage_001.json)
        resources/       # Resource definitions (resources.json)
        projectiles/     # Projectile definitions (projectiles.json)
        affinities.json  # Affinity definitions
        effects.json     # Effect definitions
        abilities.json   # Ability definitions
        match_rules.json # Match rules (victory conditions, countdown, time limit)
    rules/
        affinity_rules.json  # Affinity relationship rules
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
                         -> resources/ -> definitions/
                         -> core/
```

### Core

Autoloaded singletons and infrastructure available globally.

| Class | Responsibility |
|---|---|
| `JsonLoader` | Reads and parses JSON files. No game logic. |
| `DeckSystem` | Loads card database and builds decks from JSON. |
| `EventBus` | Global signal bus for decoupled communication between systems. Emits resource events. |
| `UnitState` | Enum and string conversion for unit states. |
| `SimulationContext` | Manages simulation time (delta_time, elapsed_time, time_scale, paused). Provides consistent time source for systems. |
| `MatchState` | Enum and string conversion for match states (LOADING, INITIALIZING, COUNTDOWN, RUNNING, PAUSED, VICTORY, DEFEAT, DRAW, FINISHED). |

### Commands

Command framework separating player intent from gameplay execution. Commands are immutable requests that never modify game state.

| Class | Type | Responsibility |
|---|---|---|
| `GameCommand` | RefCounted | Base class for all commands. Contains command_id, timestamp, metadata. Immutable after creation. |
| `PlayCardCommand` | RefCounted | Extends GameCommand. Represents player intent to spawn a unit. Carries card definition, positions, and team. |
| `AttackCommand` | RefCounted | Extends GameCommand. Represents intent to attack. Carries attacker and target references. |
| `CommandDispatcher` | RefCounted | Routes commands to responsible systems. Validates commands against EconomySystem before dispatching. Never implements gameplay logic. |

### Systems

Game logic systems that orchestrate behavior.

| Class | Type | Responsibility |
|---|---|---|
| `SpawnSystem` | RefCounted | Instantiates UnitInstance scenes via UnitFactory. |
| `FormationSystem` | Node | Detects collisions, manages battle groups and formations. |
| `SpatialQuerySystem` | RefCounted | Provides battlefield queries (frontline, units by owner/state, closest enemy, projectile collisions, units along path). Read-only. |
| `TargetingSystem` | Node | Assigns targets to melee and ranged units via SpatialQuerySystem. |
| `AttackSystem` | RefCounted | Executes attacks via AttackModelRegistry. Produces DamageAction. Emits attack events. |
| `CombatSystem` | Node | Orchestrates combat timing, dispatches AttackCommand, consumes DamageAction, applies HP. Tracks units via EventBus. Handles both melee and ranged combat. Requests CombatModifierCollection from AffinityRuleSystem and applies modifiers to damage. |
| `DeckSystem` | Node (autoload) | Loads card database and resolves deck lists. |
| `EconomySystem` | Node | Manages resources for all teams. Handles regeneration, spending, and validation. Uses SimulationContext for time-based updates. |
| `ProjectileSystem` | Node | Manages projectile movement and lifecycle. Uses SimulationContext for time-based updates. Emits projectile events. |
| `CollisionSystem` | Node | Detects projectile collisions with units. Produces DamageAction when collision occurs. Never modifies HP directly. |
| `AffinityRegistry` | RefCounted | Stores and provides lookup for affinity definitions. Validates uniqueness and provides query methods. |
| `AffinityRuleSystem` | RefCounted | Loads affinity rules from JSON, resolves attack and defense modifiers based on attacker/defender affinity pairs, and returns CombatModifierCollection objects. |
| `EffectRegistry` | RefCounted | Stores and provides lookup for effect definitions. Validates uniqueness and provides query methods. |
| `EffectLoader` | RefCounted | Static loader that reads effect definitions from JSON and populates the registry. |
| `EffectSystem` | Node | Manages effect lifecycle: create, destroy, update durations, handle stacking, refresh, emit events, dispatch triggers. Generates CombatModifiers for units. |
| `AbilityRegistry` | RefCounted | Stores and provides lookup for ability definitions. Validates uniqueness and provides query methods. |
| `AbilityLoader` | RefCounted | Static loader that reads ability definitions from JSON and populates the registry. |
| `AbilitySystem` | Node | Manages ability execution, cooldown validation, component evaluation, and command generation. Uses SimulationContext for cooldown timing. Never deals damage directly. |
| `MatchFlowSystem` | Node | Manages match lifecycle (state transitions, countdown, pause/resume, victory/defeat detection). Evaluates pluggable victory conditions. Never modifies gameplay directly. |
| `NexusSystem` | RefCounted | Manages base HP for each team. Provides damage API and emits nexus events. |

### Models

Attack model abstraction and registry.

| Class | Type | Responsibility |
|---|---|---|
| `AttackModel` | RefCounted | Abstract base class defining the attack execution contract. Returns `DamageAction`. |
| `MeleeAttackModel` | RefCounted | Calculates melee damage from attacker definition. Produces `DamageAction`. |
| `RangedAttackModel` | RefCounted | Spawns projectile for ranged attacks. Returns `DamageAction` with 0 damage (actual damage applied later by CollisionSystem). |
| `AttackModelRegistry` | RefCounted | Registers and resolves attack models by identifier. |
| `ProjectileDefinitionRegistry` | RefCounted | Registers and resolves projectile definitions by identifier. |
| `CombatModifier` | RefCounted | Represents a single combat modification with id, source, priority, operation, value, description, and metadata. |
| `CombatModifierCollection` | RefCounted | Contains multiple CombatModifier objects and provides methods to apply them in priority order to a base value. |

### Actions

Generic action framework representing gameplay operation outcomes.

| Class | Type | Responsibility |
|---|---|---|
| `GameAction` | RefCounted | Base class for all actions. Contains action_id, timestamp, source, target, metadata. Immutable after creation. |
| `DamageAction` | RefCounted | Extends GameAction with damage, critical, blocked. Created via static factory method. |

### Resources

Runtime resource state for each team.

| Class | Type | Responsibility |
|---|---|---|
| `ResourceInstance` | RefCounted | Tracks current value, generator level, and accumulated regeneration for a specific resource type. Handles regeneration logic with fractional accumulation. Emits events on changes. |

### Entities

Runtime game objects.

| Class | Type | Responsibility |
|---|---|---|
| `UnitInstance` | Node2D | Represents one spawned unit on the battlefield. Owns state, movement, and HP. |
| `BattleGroup` | RefCounted | Maintains ordered player/enemy formations. Provides frontline lookup. |
| `UnitVisualComponent` | Node | Handles all visual building and updates (HP bar, labels, target display). |
| `ProjectileInstance` | Node2D | Represents a projectile in flight. Owns position, direction, speed, owner, target, remaining_distance. Handles movement and collision detection. Supports optional debug rendering. |
| `NexusState` | RefCounted | Tracks base HP for a team. Provides is_alive(), take_damage(), get_hp_ratio(). |

**UnitInstance State Machine:** Units transition through states: MOVING → BLOCKED → ATTACKING → MOVING. When a target dies and no new target is available, units automatically resume movement via `set_moving()`. When a BattleGroup becomes empty of enemies, surviving units are released via `release_from_battle_group()`, which resets movement flags and allows them to continue toward their original destination.

### Definitions

Pure data containers parsed from JSON.

| Class | Type | Responsibility |
|---|---|---|
| `UnitDefinition` | RefCounted | Stores unit data (hp, attack, range, speed, cost, attack_model, projectile_id). |
| `StageDefinition` | RefCounted | Stores stage configuration (battlefield, spawn positions, formation spacing). |
| `DeckDefinition` | RefCounted | Stores deck card IDs. |
| `ResourceDefinition` | RefCounted | Stores resource properties (id, display_name, maximum, starting_value, regeneration_rate). Loaded from resources.json. |
| `ProjectileDefinition` | RefCounted | Stores projectile properties (id, display_name, speed, max_range, damage, projectile_type, image). Loaded from projectiles.json. |
| `AffinityDefinition` | RefCounted | Stores affinity properties (id, display_name, description, primary_color, icon, background). Loaded from affinities.json. |
| `EffectDefinition` | RefCounted | Stores effect properties (id, display_name, description, icon, stacking_policy, visual_hint, components, metadata). Components define effect behavior through composition. Loaded from effects.json. |
| `AbilityDefinition` | RefCounted | Stores ability properties (id, display_name, description, icon, cooldown, activation, pipeline, metadata). Pipeline defines ability execution through sequential node composition. Loaded from abilities.json. |
| `MatchRulesDefinition` | RefCounted | Stores match rules (countdown_duration, time_limit, nexus_hp, victory_conditions). Loaded from match_rules.json. |

### Factories

Object creation.

| Class | Type | Responsibility |
|---|---|---|
| `UnitFactory` | RefCounted | Creates UnitInstance from PackedScene and initializes with definition. |
| `ProjectileFactory` | RefCounted | Creates ProjectileInstance and initializes with ProjectileDefinition. Supports optional debug mode. |

### Effects

Runtime effect state and component-based behavior.

| Class | Type | Responsibility |
|---|---|---|
| `EffectInstance` | RefCounted | Runtime effect state: instance_id, definition, source, owner, stack_count, runtime_state, components. Delegates behavior to EffectComponent objects. |
| `EffectComponent` | RefCounted | Base interface for effect behavior components. Defines update(), get_modifiers(), is_expired() methods. |
| `DurationComponent` | EffectComponent | Manages effect duration, expiration, and refresh policy. Stores remaining_time in runtime_state. |
| `CombatModifierComponent` | EffectComponent | Generates CombatModifier objects from configuration. Supports all modifier operations and stack scaling. |

### Abilities

Runtime ability state and component-based behavior.

| Class | Type | Responsibility |
|---|---|---|
| `AbilityInstance` | RefCounted | Runtime ability activation state: instance_id, definition, owner, runtime_state, executed_components, generated_commands. Records execution details for debug. |
| `AbilityComponent` | RefCounted | Base interface for ability behavior components. Defines execute() method that returns GameCommand array. |
| `ApplyEffectComponent` | AbilityComponent | Delegates to EffectSystem.apply_effect(). Reuses existing effect infrastructure. |
| `SpawnProjectileComponent` | AbilityComponent | Delegates to ProjectileFactory.create_projectile(). Reuses existing projectile infrastructure. |
| `GenerateCommandComponent` | AbilityComponent | Creates GameCommand objects for CommandDispatcher dispatch. |

### Pipelines

Ability execution pipeline abstraction for sequential and future complex execution flows.

| Class | Type | Responsibility |
|---|---|---|
| `AbilityPipeline` | RefCounted | Ordered list of AbilityPipelineNode objects. Created from JSON or auto-migrated from component arrays. |
| `AbilityPipelineNode` | RefCounted | Wraps a component execution or future node type (delay, condition, branch). Data-driven from JSON. |
| `AbilityPipelineExecutor` | RefCounted | Executes pipeline nodes sequentially. Creates components, collects commands. |

### Conditions

Pluggable match victory/defeat conditions evaluated by MatchFlowSystem.

| Class | Type | Responsibility |
|---|---|---|
| `MatchCondition` | RefCounted | Base interface for match conditions. Defines check(context) -> bool. |
| `DestroyEnemyNexusCondition` | MatchCondition | Checks if enemy nexus HP <= 0. |
| `DestroyPlayerNexusCondition` | MatchCondition | Checks if player nexus HP <= 0. |
| `TimeLimitCondition` | MatchCondition | Checks if elapsed match time >= configured limit. |

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
| `action_performed(action)` | CombatSystem, CollisionSystem | (future) |
| `resource_changed(resource_id, current_value, maximum)` | EconomySystem | UI |
| `resource_spent(resource_id, amount, remaining)` | EconomySystem | (future) |
| `resource_generated(resource_id, amount, current_value)` | EconomySystem | (future) |
| `projectile_spawned(projectile)` | ProjectileFactory | ProjectileSystem |
| `projectile_moved(projectile)` | ProjectileSystem | (future) |
| `projectile_collided(projectile, target)` | CollisionSystem | (future) |
| `projectile_destroyed(projectile)` | ProjectileSystem, CollisionSystem | (future) |
| `effect_applied(effect)` | EffectSystem | UnitVisualComponent, Debug UI |
| `effect_removed(effect)` | EffectSystem | UnitVisualComponent, Debug UI |
| `effect_expired(effect)` | EffectSystem | UnitVisualComponent, Debug UI |
| `effect_refreshed(effect)` | EffectSystem | UnitVisualComponent, Debug UI |
| `effect_stack_changed(effect)` | EffectSystem | UnitVisualComponent, Debug UI |
| `ability_started(ability)` | AbilitySystem | Debug UI |
| `ability_finished(ability)` | AbilitySystem | Debug UI |
| `ability_cancelled(ability_id, owner)` | AbilitySystem | (future) |
| `ability_cooldown_started(ability_id, owner, duration)` | AbilitySystem | Ability UI |
| `ability_ready(ability_id, owner)` | AbilitySystem | Ability UI |
| `match_started` | MatchFlowSystem | BattleScene |
| `match_paused` | MatchFlowSystem | BattleScene |
| `match_resumed` | MatchFlowSystem | BattleScene |
| `match_finished(winner, loser, elapsed_time)` | MatchFlowSystem | BattleScene |
| `victory(winner, condition)` | MatchFlowSystem | BattleScene |
| `defeat(loser, condition)` | MatchFlowSystem | BattleScene |
| `draw(condition)` | MatchFlowSystem | BattleScene |
| `countdown_started(duration)` | MatchFlowSystem | BattleScene |
| `nexus_damaged(team, current_hp, max_hp)` | NexusSystem | BattleScene |
| `nexus_destroyed(team)` | NexusSystem | MatchFlowSystem |

## Gameplay Flow

```
BattleScene._ready()
  -> Load stage from JSON
  -> Setup SimulationContext
  -> Setup systems (SpawnSystem, FormationSystem, SpatialQuerySystem, TargetingSystem, AttackSystem, CombatSystem, EconomySystem)
  -> Setup CommandDispatcher (with EconomySystem for validation)
  -> Load decks from JSON
  -> Create card button UI
  -> Setup resource panel UI

BattleScene._physics_process(delta)
  -> SimulationContext.update(delta)
  -> EconomySystem regenerates resources
  -> Update resource panel UI
  -> Update card affordability (grey out unaffordable cards)

Player clicks card button
  -> PlayCardCommand.create()
  -> CommandDispatcher.dispatch(command)
     -> EconomySystem.can_afford() validation
     -> If affordable: EconomySystem.spend()
     -> If not affordable: return null (command rejected)
     -> SpawnSystem.spawn_unit()
        -> UnitFactory.create_unit()
        -> UnitInstance.configure_movement()
        -> EventBus.unit_spawned emitted

AI spawn timer
  -> Check if AI can afford card
  -> If affordable: PlayCardCommand.create() -> dispatch
  -> If not affordable: skip this frame

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
        -> For melee: MeleeAttackModel.execute() -> DamageAction
        -> For ranged: RangedAttackModel.execute()
           -> Resolve ProjectileDefinition
           -> ProjectileFactory.create_projectile()
           -> EventBus.projectile_spawned emitted
           -> Return DamageAction(0) (damage applied later)
        -> EventBus.attack_started / attack_finished emitted
  -> Consume DamageAction via target.take_damage()
  -> EventBus.action_performed emitted with DamageAction

ProjectileSystem._physics_process()
  -> Update all projectile positions using SimulationContext.delta_time
  -> EventBus.projectile_moved emitted
  -> Cleanup expired projectiles
  -> EventBus.projectile_destroyed emitted

CollisionSystem._physics_process()
  -> Check projectile collisions with units
  -> If collision detected:
     -> EventBus.projectile_collided emitted
     -> Create DamageAction with projectile damage
     -> EventBus.action_performed emitted
     -> CombatSystem consumes DamageAction, applies HP
     -> EventBus.projectile_destroyed emitted

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
- [x] **Milestone 9** - Economy Layer: EconomySystem, ResourceDefinition, ResourceInstance, SimulationContext, command validation, resource regeneration
- [x] **Milestone 10** - Projectile Layer: ProjectileDefinition, ProjectileInstance, ProjectileFactory, ProjectileSystem, CollisionSystem, RangedAttackModel, projectile collision detection
- [x] **Milestone 11** - Affinity Rule Engine: AffinityDefinition, AffinityRegistry, AffinityRuleSystem, CombatModifier, CombatModifierCollection, affinity-based damage modifiers, UI affinity display
- [x] **Milestone 12** - Effect Engine: EffectDefinition, EffectRegistry, EffectLoader, EffectInstance, EffectSystem, effect lifecycle, stacking policies, trigger infrastructure, CombatModifier generation, effect icon UI, debug panel
- [x] **Milestone 13** - Ability Composition Engine: AbilityDefinition, AbilityRegistry, AbilityLoader, AbilityInstance, AbilityComponent, ApplyEffectComponent, SpawnProjectileComponent, GenerateCommandComponent, AbilitySystem, cooldown management, ability UI, debug panel
- [x] **Milestone 14** - Match Flow Engine: MatchState, MatchFlowSystem, MatchRulesDefinition, NexusState, NexusSystem, MatchCondition, DestroyEnemyNexusCondition, DestroyPlayerNexusCondition, TimeLimitCondition, AbilityPipeline, AbilityPipelineNode, AbilityPipelineExecutor, match UI, countdown, victory/defeat display

### Planned

- [ ] **Milestone 15** - AI Layer: AI decision making, strategy, deck building
- [ ] **Milestone 16** - Content Pipeline: tools, editors, content creation workflow
- [ ] **Milestone 17** - Replay & Deterministic Simulation
- [ ] **Milestone 18** - Animations and visual effects
- [ ] **Milestone 19** - Audio: sound effects, music
- [ ] **Milestone 20** - Menus, settings, save system

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
