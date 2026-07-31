# Architecture

## High-Level Architecture

Bellum Aetatum uses a layered architecture with clear separation of concerns. The design follows data-driven principles where game content is defined in JSON files and interpreted at runtime.

```
+------------------------------------------------------------------+
|                         Scenes Layer                              |
|  BattleScene - coordinates systems, handles input, manages UI     |
+------------------------------------------------------------------+
         |              |              |              |
         v              v              v              v
+------------------------------------------------------------------+
|                        Systems Layer                              |
|  SpawnSystem | FormationSystem | TargetingSystem | CombatSystem  |
|  AttackSystem | DeckSystem                                       |
+------------------------------------------------------------------+
         |              |              |
         v              v              v
+------------------------------------------------------------------+
|                        Models Layer                               |
|  AttackModelRegistry | AttackModel | MeleeAttackModel            |
|  DamageResult                                                    |
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

- **EventBus**: Global signal bus. All inter-system communication flows through EventBus signals. Systems emit and listen to signals without knowing about each other.
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

### Models Layer

Attack model abstraction and registry.

- **AttackModel**: Abstract base class defining the `execute(attacker, target) -> DamageResult` contract.
- **MeleeAttackModel**: Implements melee damage calculation.
- **AttackModelRegistry**: Registers and resolves attack models by string identifier.
- **DamageResult**: Data carrier for attack results.

### Systems Layer

Game logic systems that orchestrate behavior.

- **SpawnSystem**: Creates UnitInstance via UnitFactory. Emits `unit_spawned`.
- **FormationSystem**: Detects collisions, creates BattleGroups, manages formation positioning.
- **TargetingSystem**: Assigns targets to melee units based on BattleGroup formations.
- **AttackSystem**: Executes attacks via AttackModelRegistry. Emits `attack_started` and `attack_finished`.
- **CombatSystem**: Orchestrates combat timing, delegates to AttackSystem, applies DamageResult.
- **DeckSystem**: Loads card database and resolves deck lists from JSON.

### Factories Layer

Object creation logic.

- **UnitFactory**: Creates UnitInstance from PackedScene and initializes with UnitDefinition.

### Scenes Layer

Scene coordination.

- **BattleScene**: Coordinates all systems. Handles input, manages UI, triggers spawning.

## Dependency Direction

Dependencies flow strictly inward. Outer layers depend on inner layers, never the reverse.

```
Scenes -> Systems -> Models -> Entities -> Definitions -> Core
                    -> Entities -> Definitions
                    -> Core
```

Specifically:

- **BattleScene** depends on all systems, definitions, and core.
- **CombatSystem** depends on AttackSystem, FormationSystem, EventBus, UnitInstance.
- **AttackSystem** depends on AttackModelRegistry, EventBus, UnitInstance.
- **AttackModelRegistry** depends on AttackModel.
- **MeleeAttackModel** depends on AttackModel, UnitInstance, DamageResult.
- **UnitInstance** depends on UnitDefinition, UnitVisualComponent, EventBus, UnitState.
- **FormationSystem** depends on BattleGroup, UnitInstance, EventBus, UnitState.
- **TargetingSystem** depends on FormationSystem, BattleGroup, UnitInstance, EventBus.

## Communication Through EventBus

Systems avoid direct coupling by communicating through EventBus signals.

### Signal Flow

```
SpawnSystem          --[unit_spawned]--------> FormationSystem
UnitInstance         --[unit_died]-----------> FormationSystem, CombatSystem
FormationSystem      --[frontline_changed]---> (future listeners)
TargetingSystem      --[target_changed]------> (future listeners)
AttackSystem         --[attack_started]------> (future listeners)
AttackSystem         --[attack_finished]-----> (future listeners)
UnitInstance         --[unit_damaged]--------> (future listeners)
```

### Rules

1. Systems emit signals to announce events.
2. Systems listen to signals to react to events.
3. Systems never call methods on other systems directly (except through initialization injection).
4. EventBus is the only shared global state.

## Object Lifecycle

### UnitInstance Lifecycle

```
1. BattleScene._on_card_pressed()
2. SpawnSystem.spawn_unit()
   a. UnitFactory.create_unit() - instantiates PackedScene
   b. UnitInstance.initialize() - sets definition, hp, visuals
   c. UnitInstance.configure_movement() - sets target position
3. EventBus.unit_spawned emitted
4. FormationSystem registers unit
5. UnitInstance._physics_process() runs each frame
   a. State machine drives behavior
   b. Movement toward formation or target position
   c. Target validation
6. CombatSystem triggers attacks via AttackSystem
7. UnitInstance.take_damage() reduces HP
8. UnitInstance dies -> EventBus.unit_died emitted
9. FormationSystem removes unit and frees node
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
     -> _update_enemy_spawn_timer() -> SpawnSystem.spawn_unit()

  2. FormationSystem._physics_process()
     -> _cleanup_invalid_units()
     -> _detect_collisions()
     -> _update_formations()

  3. TargetingSystem._physics_process()
     -> _update_targets_for_group() for each BattleGroup

  4. CombatSystem._physics_process()
     -> _cleanup_timers()
     -> _process_group() for each BattleGroup
        -> _process_unit_combat() for each alive unit
           -> _update_attack_timer()
              -> AttackSystem.execute()
                 -> AttackModelRegistry.resolve()
                 -> MeleeAttackModel.execute()
              -> _apply_damage_result()

  5. UnitInstance._physics_process() (each unit)
     -> _validate_target()
     -> State machine processing
```

### Attack Execution Flow

```
CombatSystem._update_attack_timer()
  -> timer reaches interval (1.0 / attack_speed)
  -> AttackSystem.execute(attacker, target)
     -> EventBus.attack_started.emit(attacker, target)
     -> _resolve_damage(attacker, target)
        -> model_key = attacker.definition.attack_model
        -> AttackModelRegistry.resolve(model_key)
        -> model.execute(attacker, target)
           -> MeleeAttackModel: DamageResult { damage: attacker.definition.attack }
     -> EventBus.attack_finished.emit(attacker, target, result)
  -> CombatSystem._apply_damage_result(result)
     -> target.take_damage(result.damage)
        -> EventBus.unit_damaged.emit(target, damage)
        -> if not alive: EventBus.unit_died.emit(target)
```
