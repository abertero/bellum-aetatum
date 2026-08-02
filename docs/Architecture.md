# Architecture

## High-Level Architecture

Bellum Aetatum uses a layered architecture with clear separation of concerns. The design follows data-driven principles where game content is defined in JSON files and interpreted at runtime.

```
+------------------------------------------------------------------+
|                      Input / Presentation Layer                   |
|  BattleScene (UI) | AI (future) | Replay (future)                |
+------------------------------------------------------------------+
         |              |              |              |
         v              v              v              v
+------------------------------------------------------------------+
|                       Commands Layer                              |
|  GameCommand | PlayCardCommand | AttackCommand | CommandDispatcher|
+------------------------------------------------------------------+
         |              |              |
         v              v              v
+------------------------------------------------------------------+
|                        Systems Layer                              |
|  SpawnSystem | FormationSystem | SpatialQuerySystem              |
|  TargetingSystem | CombatSystem | AttackSystem | DeckSystem      |
+------------------------------------------------------------------+
         |              |              |
         v              v              v
+------------------------------------------------------------------+
|                        Actions Layer                              |
|  GameAction | DamageAction                                       |
+------------------------------------------------------------------+
         |              |
         v              v
+------------------------------------------------------------------+
|                        Models Layer                               |
|  AttackModelRegistry | AttackModel | MeleeAttackModel            |
+------------------------------------------------------------------+
         |              |
         v              v
+------------------------------------------------------------------+
|                       Entities Layer                              |
|  UnitInstance | BattleGroup | UnitVisualComponent                |
+------------------------------------------------------------------+
         |              |
         v              v
+------------------------------------------------------------------+
|                     Definitions Layer                             |
|  UnitDefinition | StageDefinition | DeckDefinition               |
+------------------------------------------------------------------+
         |
         v
+------------------------------------------------------------------+
|                         Core Layer                                |
|  EventBus | JsonLoader | UnitState                                |
+------------------------------------------------------------------+
         |
         v
+------------------------------------------------------------------+
|                       Factories Layer                             |
|  UnitFactory                                                      |
+------------------------------------------------------------------+
         |
         v
+------------------------------------------------------------------+
|                         Data Layer                                |
|  cards.json | player_deck.json | enemy_deck.json | stage_001.json|
+------------------------------------------------------------------+
```

## Layer Responsibilities

### Core Layer

Autoloaded singletons providing infrastructure services available globally.

- **EventBus**: Global signal bus. All inter-system communication flows through EventBus signals. Systems emit and listen to signals without knowing about each other. Broadcasts `GameAction` objects for gameplay operations.
- **JsonLoader**: Reads JSON files from disk and returns parsed data. Has no knowledge of game concepts.
- **UnitState**: Enum defining unit states (MOVING, WAITING, BLOCKED, ATTACKING, DEAD) and string conversion utility.

### Definitions Layer

Pure data containers that hold configuration parsed from JSON. No behavior, no mutable gameplay state.

- **UnitDefinition**: Unit statistics (hp, attack, range, speed, cost, attack_speed, attack_model).
- **StageDefinition**: Stage configuration (battlefield_width, spawn positions, formation_spacing).
- **DeckDefinition**: Deck card ID list.

### Entities Layer

Runtime game objects that exist in the scene tree.

- **UnitInstance**: Represents one spawned unit. Owns mutable state (current_hp, current_state, current_target, battle_group). Delegates visuals to UnitVisualComponent.
- **BattleGroup**: Organizes units into ordered player/enemy formations. Provides frontline lookup.
- **UnitVisualComponent**: Handles all visual building and updates (HP bar, labels, target display).

#### UnitInstance State Transitions

UnitInstance uses a state machine with the following states and transitions:

```
MOVING: Unit is advancing toward target position
  ↓ (collision detected or target acquired)
BLOCKED: Unit is waiting in formation
  ↓ (target assigned by TargetingSystem)
ATTACKING: Unit is engaged in combat
  ↓ (target dies or becomes invalid)
MOVING: Unit resumes advancement
```

State transition methods:
- `set_battle_group()`: MOVING → BLOCKED
- `set_formation_target()`: BLOCKED → WAITING
- `set_attacking()`: any → ATTACKING
- `set_blocked()`: ATTACKING → BLOCKED
- `set_moving()`: ATTACKING or BLOCKED → MOVING (when no valid target exists)

The `set_moving()` transition ensures units resume advancement when their target dies and no new target is available.

### Models Layer

Attack model abstraction and registry.

- **AttackModel**: Abstract base class defining the `execute(attacker, target) -> DamageAction` contract.
- **MeleeAttackModel**: Implements melee damage calculation, produces `DamageAction`.
- **AttackModelRegistry**: Registers and resolves attack models by string identifier.

### Actions Layer

Generic action framework representing gameplay operation outcomes.

- **GameAction**: Base class for all actions. Contains `action_id`, `timestamp`, `source`, `target`, `metadata`. Immutable after creation.
- **DamageAction**: Extends `GameAction` with `damage`, `critical`, `blocked`. Created via `DamageAction.create()` factory method.

### Commands Layer

Command framework separating player intent from gameplay execution.

- **GameCommand**: Base class for all commands. Contains `command_id`, `timestamp`, `metadata`. Immutable after creation. Commands are requests, never modify game state.
- **PlayCardCommand**: Extends `GameCommand` with `card_definition`, `spawn_position`, `target_position`, `parent`, `team`. Created via factory method.
- **AttackCommand**: Extends `GameCommand` with `attacker`, `target`. Created via factory method.
- **CommandDispatcher**: Routes commands to responsible systems. Never implements gameplay logic. Translates command data into system method calls.

### Systems Layer

Game logic systems that orchestrate behavior.

- **SpawnSystem**: Creates UnitInstance via UnitFactory. Emits `unit_spawned`.
- **FormationSystem**: Detects collisions, creates BattleGroups, manages formation positioning.
- **SpatialQuerySystem**: Provides battlefield queries (frontline, units by owner/state, closest enemy). Read-only — never modifies state.
- **TargetingSystem**: Assigns targets to melee units based on SpatialQuerySystem queries.
- **AttackSystem**: Executes attacks via AttackModelRegistry. Produces `DamageAction`. Emits `attack_started` and `attack_finished`.
- **CombatSystem**: Orchestrates combat timing, dispatches `AttackCommand`, consumes `DamageAction`, applies HP changes. Tracks units via EventBus.
- **DeckSystem**: Loads card database and resolves deck lists from JSON.

### Factories Layer

Object creation logic.

- **UnitFactory**: Creates UnitInstance from PackedScene and initializes with UnitDefinition.

### Scenes Layer

Scene coordination.

- **BattleScene**: Coordinates all systems. Handles input, manages UI, dispatches `PlayCardCommand`.

## Dependency Direction

Dependencies flow strictly inward. Outer layers depend on inner layers, never the reverse.

```
Input -> Commands -> Systems -> Actions -> Models -> Entities -> Definitions -> Core
                     -> Actions -> Models
                     -> Entities -> Definitions
                     -> Core
```

Specifically:

- **BattleScene** depends on CommandDispatcher, all systems, definitions, and core.
- **CommandDispatcher** depends on Commands, SpawnSystem, AttackSystem.
- **CombatSystem** depends on CommandDispatcher, EventBus, UnitInstance, DamageAction.
- **TargetingSystem** depends on SpatialQuerySystem, EventBus, UnitInstance.
- **SpatialQuerySystem** depends on FormationSystem, BattleGroup, UnitInstance.
- **AttackSystem** depends on AttackModelRegistry, EventBus, UnitInstance, DamageAction.
- **AttackModelRegistry** depends on AttackModel.
- **MeleeAttackModel** depends on AttackModel, UnitInstance, DamageAction.
- **DamageAction** depends on GameAction.
- **PlayCardCommand** depends on GameCommand, UnitDefinition.
- **AttackCommand** depends on GameCommand, UnitInstance.
- **UnitInstance** depends on UnitDefinition, UnitVisualComponent, EventBus, UnitState.
- **FormationSystem** depends on BattleGroup, UnitInstance, EventBus, UnitState.

## Communication: Commands vs Actions

The architecture uses two distinct communication patterns:

### Commands (Requests)

Commands represent player or AI intent. They flow inward through CommandDispatcher.

```
Input Source -> GameCommand -> CommandDispatcher -> System
```

- Commands never travel through EventBus.
- Commands are synchronous requests.
- Commands never modify game state directly.
- Systems execute commands and produce actions.

### Actions (Results)

Actions represent outcomes of executed commands. They flow outward through EventBus.

```
System -> GameAction -> EventBus -> Listeners
```

- Actions are broadcast via EventBus signals.
- Actions are asynchronous notifications.
- Actions are immutable records of what happened.
- Any system can listen to actions without coupling.

### Signal Flow

```
SpawnSystem          --[unit_spawned]--------> FormationSystem, CombatSystem
UnitInstance         --[unit_died]-----------> FormationSystem, CombatSystem
FormationSystem      --[frontline_changed]---> (future listeners)
TargetingSystem      --[target_changed]------> (future listeners)
AttackSystem         --[attack_started]------> (future listeners)
AttackSystem         --[attack_finished]-----> (future listeners)
CombatSystem         --[action_performed]----> (future listeners)
```

### Rules

1. Input sources create commands and dispatch them.
2. CommandDispatcher routes commands to systems.
3. Systems execute commands and produce actions.
4. Systems emit signals to announce events.
5. Systems listen to signals to react to events.
6. Systems never call methods on other systems directly (except through initialization injection).
7. EventBus is the only shared global state.
8. Gameplay actions are broadcast as `GameAction` objects, not primitive values.
9. Commands never travel through EventBus.

## Object Lifecycle

### UnitInstance Lifecycle

```
1. Player clicks card button
2. BattleScene creates PlayCardCommand
3. CommandDispatcher.dispatch(command)
4. SpawnSystem.spawn_unit()
   a. UnitFactory.create_unit() - instantiates PackedScene
   b. UnitInstance.initialize() - sets definition, hp, visuals
   c. UnitInstance.configure_movement() - sets target position
5. EventBus.unit_spawned emitted
6. FormationSystem registers unit
7. UnitInstance._physics_process() runs each frame
   a. State machine drives behavior
   b. Movement toward formation or target position
   c. Target validation
8. CombatSystem detects attack timer expiry
9. CombatSystem creates AttackCommand
10. CommandDispatcher.dispatch(command)
11. AttackSystem produces DamageAction
12. CombatSystem consumes DamageAction, applies HP via target.take_damage()
13. EventBus.action_performed emitted with DamageAction
14. UnitInstance dies -> EventBus.unit_died emitted
15. FormationSystem removes unit and frees node
16. Surviving unit's target is now null
17. CombatSystem detects no valid target, transitions unit to MOVING state
18. Unit resumes movement toward original target position
```

### BattleGroup Lifecycle

```
1. FormationSystem detects collision between opposing units
2. BattleGroup created at collision midpoint
3. Units added to player_formation or enemy_formation
4. Units positioned with formation_spacing offset
5. TargetingSystem reads formations to assign targets
6. When frontline dies, next unit becomes frontline
7. FormationSystem removes dead units via cleanup()
```

## Runtime Flow

### Per-Frame Update Order

```
_physics_process(delta):
  1. BattleScene._physics_process()
     -> _update_enemy_spawn_timer()
        -> PlayCardCommand -> CommandDispatcher -> SpawnSystem
     -> _update_debug_panel()

  2. FormationSystem._physics_process()
     -> _cleanup_invalid_units()
     -> _detect_collisions()
     -> _update_formations()

  3. TargetingSystem._physics_process()
     -> _assign_targets_for_team() for each team
        -> SpatialQuerySystem.get_units_in_formation()
        -> SpatialQuerySystem.get_frontline()

  4. CombatSystem._physics_process()
     -> _cleanup_timers()
     -> _cleanup_tracked_units()
     -> _process_all_units()
        -> _process_unit_combat() for each unit with target
           -> _update_attack_timer()
              -> AttackCommand -> CommandDispatcher
                 -> AttackSystem.execute()
                    -> AttackModelRegistry.resolve()
                    -> MeleeAttackModel.execute() -> DamageAction
              -> _apply_damage_action()
                 -> target.take_damage()
                 -> EventBus.action_performed.emit(action)

  5. UnitInstance._physics_process() (each unit)
     -> _validate_target()
     -> State machine processing
```

### Command Execution Flow

```
Player Input / AI / Replay
  -> Create GameCommand (immutable request)
  -> CommandDispatcher.dispatch(command)
     -> Route to appropriate system
     -> System executes command
     -> System produces GameAction (if applicable)
  -> EventBus broadcasts GameAction
  -> Listeners react to GameAction
```

### Attack Execution Flow

```
CombatSystem._update_attack_timer()
  -> timer reaches interval (1.0 / attack_speed)
  -> AttackCommand.create(attacker, target)
  -> CommandDispatcher.dispatch(command)
     -> AttackSystem.execute(attacker, target)
        -> EventBus.attack_started.emit(attacker, target)
        -> _resolve_damage(attacker, target)
           -> model_key = attacker.definition.attack_model
           -> AttackModelRegistry.resolve(model_key)
           -> model.execute(attacker, target)
              -> MeleeAttackModel: DamageAction.create(attacker.definition.attack, attacker, target)
        -> EventBus.attack_finished.emit(action)
  -> CombatSystem._apply_damage_action(action)
     -> target.take_damage(action.damage)
        -> if not alive: EventBus.unit_died.emit(target)
     -> EventBus.action_performed.emit(action)
```
