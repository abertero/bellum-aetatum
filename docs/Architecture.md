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
|  EconomySystem | ProjectileSystem | CollisionSystem              |
|  AffinityRegistry | AffinityRuleSystem                           |
|  EffectRegistry | EffectLoader | EffectSystem                    |
|  AbilityRegistry | AbilityLoader | AbilitySystem                  |
|  MatchFlowSystem | NexusSystem                                      |
+------------------------------------------------------------------+
         |              |              |
         v              v              v
+------------------------------------------------------------------+
|                    Replay Layer                                   |
|  ReplayDefinition | ReplayRecorder | ReplayPlayer                |
|  ReplayValidator  | StateHasher                                   |
+------------------------------------------------------------------+
         |              |              |
         v              v              v
+------------------------------------------------------------------+
|                    Schema Layer                                   |
|  SchemaVersion | SchemaValidator | ContentMigrationRegistry       |
|  ContentVersion                                                 |
+------------------------------------------------------------------+
         |              |              |
         v              v              v
+------------------------------------------------------------------+
|                      AI Decision Engine                           |
|  WorldState | PerceptionSystem | EvaluationSystem                |
|  DecisionSystem | AICommandGenerator | AIDecisionEngine          |
|  AIRegistry | AILoader | AIEvaluationResult | AIDebugData        |
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
|  RangedAttackModel | ProjectileDefinitionRegistry                |
|  CombatModifier | CombatModifierCollection                       |
+------------------------------------------------------------------+
         |              |
         v              v
+------------------------------------------------------------------+
|                       Entities Layer                              |
|  UnitInstance | BattleGroup | UnitVisualComponent                |
|  ProjectileInstance | NexusState                                   |
+------------------------------------------------------------------+
         |              |
         v              v
+------------------------------------------------------------------+
|                      Resources Layer                              |
|  ResourceInstance                                                 |
+------------------------------------------------------------------+
          |              |
          v              v
+------------------------------------------------------------------+
|                        Effects Layer                              |
|  EffectInstance | EffectComponent | DurationComponent             |
|  CombatModifierComponent                                          |
+------------------------------------------------------------------+
           |              |
           v              v
+------------------------------------------------------------------+
|                       Abilities Layer                             |
|  AbilityInstance | AbilityComponent | ApplyEffectComponent       |
|  SpawnProjectileComponent | GenerateCommandComponent             |
+------------------------------------------------------------------+
            |              |
            v              v
+------------------------------------------------------------------+
|                       Pipelines Layer                             |
|  AbilityPipeline | AbilityPipelineNode | AbilityPipelineExecutor |
+------------------------------------------------------------------+
            |              |
            v              v
+------------------------------------------------------------------+
|                      Conditions Layer                             |
|  MatchCondition | DestroyEnemyNexusCondition                     |
|  DestroyPlayerNexusCondition | TimeLimitCondition                |
+------------------------------------------------------------------+
           |              |
           v              v
+------------------------------------------------------------------+
|                     Definitions Layer                             |
|  UnitDefinition | StageDefinition | DeckDefinition               |
|  ResourceDefinition | ProjectileDefinition | AffinityDefinition  |
|  EffectDefinition                                       |
|  AbilityDefinition | MatchRulesDefinition               |
|  AIPersonalityDefinition | GameModeDefinition           |
+------------------------------------------------------------------+
         |
         v
+------------------------------------------------------------------+
|                         Core Layer                                |
|  EventBus | JsonLoader | UnitState | SimulationContext            |
|  MatchState                                                       |
+------------------------------------------------------------------+
         |
         v
+------------------------------------------------------------------+
|                       Factories Layer                             |
|  UnitFactory | ProjectileFactory                                  |
+------------------------------------------------------------------+
         |
         v
+------------------------------------------------------------------+
|                         Data Layer                                |
|  cards.json | player_deck.json | enemy_deck.json | stage_001.json|
|  resources.json | projectiles.json | affinities.json             |
|  effects.json                                                  |
|  abilities.json                                                |
|  match_rules.json                                              |
|  ai_personalities.json | game_modes.json                        |
|  rules/affinity_rules.json                                       |
+------------------------------------------------------------------+
```

## Layer Responsibilities

### Core Layer

Autoloaded singletons and infrastructure services available globally.

- **EventBus**: Global signal bus. All inter-system communication flows through EventBus signals. Systems emit and listen to signals without knowing about each other. Broadcasts `GameAction` objects for gameplay operations. Emits resource events (`resource_changed`, `resource_spent`, `resource_generated`).
- **JsonLoader**: Reads JSON files from disk and returns parsed data. Has no knowledge of game concepts.
- **UnitState**: Enum defining unit states (MOVING, WAITING, BLOCKED, ATTACKING, DEAD) and string conversion utility.
- **SimulationContext**: Manages simulation time with fixed timestep (tick, fixed_delta_time, accumulator, elapsed_time, time_scale, paused, random_seed). Provides DeterministicRandom for all gameplay randomness. Uses accumulator pattern: real frame time accumulates, then fixed-size ticks are consumed. Updated by BattleScene in `_physics_process()`. Never queries engine clock directly.
- **MatchState**: Enum defining match lifecycle states (LOADING, INITIALIZING, COUNTDOWN, RUNNING, PAUSED, VICTORY, DEFEAT, DRAW, FINISHED) and string conversion utility.
- **DeterministicRandom**: LCG-based deterministic random number generator. Seeded from SimulationContext. Supports: next_int, next_int_range, next_float, next_float_range, next_bool, select_from. Same seed and call sequence always produces identical results.
- **CommandRecord**: Serializable wrapper for GameCommand. Contains command_id, tick, source, command_type, payload, sequence_number, metadata.
- **CommandLog**: Ordered log of all dispatched commands. Records commands with sequence numbers. Supports querying by tick, serialization/deserialization.
- **MatchSnapshot**: Serializable snapshot of full simulation state. Contains: simulation_tick, elapsed_time, random_seed, match_state, world_state, economy_state, active_effects, active_projectiles, active_units, cooldowns, command_sequence, content_version, game_mode_id.

### Definitions Layer

Pure data containers that hold configuration parsed from JSON. No behavior, no mutable gameplay state.

- **UnitDefinition**: Unit statistics (hp, attack, range, speed, cost, attack_speed, attack_model, projectile_id, affinity_id).
- **StageDefinition**: Stage configuration (battlefield_width, spawn positions, formation_spacing).
- **DeckDefinition**: Deck card ID list.
- **ResourceDefinition**: Resource properties (id, display_name, maximum, starting_value, regeneration_rate). Loaded from `data/resources/resources.json`.
- **ProjectileDefinition**: Projectile properties (id, display_name, speed, max_range, damage, projectile_type, image). Loaded from `data/projectiles/projectiles.json`.
- **AffinityDefinition**: Affinity properties (id, display_name, description, primary_color, icon, background). Loaded from `data/affinities.json`.
- **EffectDefinition**: Effect properties (id, display_name, description, icon, duration, stacking_policy, refresh_policy, visual_hint, triggers, modifiers, metadata). Loaded from `data/effects.json`.
- **AbilityDefinition**: Ability properties (id, display_name, description, icon, cooldown, activation, pipeline, metadata). Pipeline defines ability execution through sequential node composition. Loaded from `data/abilities.json`.
- **MatchRulesDefinition**: Match rules (countdown_duration, time_limit, nexus_hp, victory_conditions). Loaded from `data/match_rules.json`.

### Entities Layer

Runtime game objects that exist in the scene tree.

- **UnitInstance**: Represents one spawned unit. Owns mutable state (current_hp, current_state, current_target, battle_group). Delegates visuals to UnitVisualComponent.
- **BattleGroup**: Organizes units into ordered player/enemy formations. Provides frontline lookup.
- **UnitVisualComponent**: Handles all visual building and updates (HP bar, labels, target display).
- **ProjectileInstance**: Represents a projectile in flight. Owns position, direction, speed, owner, target, remaining_distance. Handles movement and collision detection. Supports optional debug rendering.
- **NexusState**: Tracks base HP for a team. Provides `is_alive()`, `take_damage()`, `get_hp_ratio()`. Created by NexusSystem.

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
- `release_from_battle_group()`: any → MOVING (when BattleGroup is empty of enemies)

The `set_moving()` transition ensures units resume advancement when their target dies and no new target is available.

The `release_from_battle_group()` method is called by FormationSystem when a BattleGroup becomes empty of enemies. It clears the battle_group reference, resets movement flags (`_has_reached_target`, `_has_formation_target`), and transitions the unit to MOVING state so it can continue toward its original target position.

### Resources Layer

Runtime resource state for each team.

- **ResourceInstance**: Tracks current value, generator level, and accumulated regeneration for a specific resource type. Handles regeneration logic with fractional accumulation. Emits events on changes.

### Effects Layer

Runtime effect state and component-based behavior.

- **EffectInstance**: Runtime effect object. Stores instance_id, definition, source, owner, stack_count, runtime_state, components. Delegates behavior to EffectComponent objects. Lightweight runtime container.
- **EffectComponent**: Base interface for effect behavior components. Defines update(), get_modifiers(), is_expired() methods. Components are composed to create effect behaviors.
- **DurationComponent**: Manages effect duration, expiration, and refresh policy. Stores remaining_time in runtime_state. Uses SimulationContext for time.
- **CombatModifierComponent**: Generates CombatModifier objects from configuration. Supports all modifier operations (MULTIPLY, ADD, OVERRIDE, MIN, MAX) and stack scaling.

### Models Layer

Attack model abstraction and registry.

- **AttackModel**: Abstract base class defining the `execute(attacker, target) -> DamageAction` contract.
- **MeleeAttackModel**: Implements melee damage calculation, produces `DamageAction`.
- **RangedAttackModel**: Implements ranged attack by spawning a projectile. Returns a `DamageAction` with 0 damage (actual damage applied later by CollisionSystem).
- **AttackModelRegistry**: Registers and resolves attack models by string identifier.
- **ProjectileDefinitionRegistry**: Registers and resolves projectile definitions by string identifier.
- **CombatModifier**: Represents a single combat modification with id, source, priority, operation, value, description, and metadata.
- **CombatModifierCollection**: Contains multiple CombatModifier objects and provides methods to apply them in priority order to a base value.

### Actions Layer

Generic action framework representing gameplay operation outcomes.

- **GameAction**: Base class for all actions. Contains `action_id`, `timestamp`, `source`, `target`, `metadata`. Immutable after creation.
- **DamageAction**: Extends `GameAction` with `damage`, `critical`, `blocked`. Created via `DamageAction.create()` factory method.

### Commands Layer

Command framework separating player intent from gameplay execution.

- **GameCommand**: Base class for all commands. Contains `command_id`, `timestamp`, `metadata`. Immutable after creation. Commands are requests, never modify game state.
- **PlayCardCommand**: Extends `GameCommand` with `card_definition`, `spawn_position`, `target_position`, `parent`, `team`. Created via factory method.
- **AttackCommand**: Extends `GameCommand` with `attacker`, `target`. Created via factory method.
- **CommandDispatcher**: Routes commands to responsible systems. Validates commands against EconomySystem before dispatching. Never implements gameplay logic. Translates command data into system method calls.

### Systems Layer

Game logic systems that orchestrate behavior.

- **SpawnSystem**: Creates UnitInstance via UnitFactory. Emits `unit_spawned`.
- **FormationSystem**: Detects collisions, creates BattleGroups, manages formation positioning.
- **SpatialQuerySystem**: Provides battlefield queries (frontline, units by owner/state, closest enemy, projectile collisions, units along path). Read-only — never modifies state.
- **TargetingSystem**: Assigns targets to melee and ranged units based on SpatialQuerySystem queries.
- **AttackSystem**: Executes attacks via AttackModelRegistry. Produces `DamageAction`. Emits `attack_started` and `attack_finished`.
- **CombatSystem**: Orchestrates combat timing, dispatches `AttackCommand`, consumes `DamageAction`, applies HP changes. Tracks units via EventBus. Handles both melee and ranged combat. Requests CombatModifierCollection from AffinityRuleSystem and EffectSystem, merges modifiers, and applies to damage.
- **DeckSystem**: Loads card database and resolves deck lists from JSON.
- **EconomySystem**: Manages resources for all teams. Handles regeneration, spending, and validation. Uses SimulationContext for time-based updates.
- **ProjectileSystem**: Manages projectile movement and lifecycle. Uses SimulationContext for time-based updates. Emits `projectile_spawned`, `projectile_moved`, `projectile_destroyed`.
- **CollisionSystem**: Detects projectile collisions with units. Produces `DamageAction` when collision occurs. Emits `projectile_collided`. Never modifies HP directly.
- **AffinityRegistry**: Stores and provides lookup for affinity definitions. Validates uniqueness and provides query methods.
- **AffinityRuleSystem**: Loads affinity rules from JSON, resolves attack and defense modifiers based on attacker/defender affinity pairs, and returns CombatModifierCollection objects.
- **EffectRegistry**: Stores and provides lookup for effect definitions. Validates uniqueness and provides query methods.
- **EffectLoader**: Static loader that reads effect definitions from JSON and populates the registry.
- **EffectSystem**: Manages effect lifecycle: create, destroy, update durations, handle stacking, refresh, emit events, dispatch triggers. Generates CombatModifiers for units. Never modifies HP directly. Never updates UI.
- **AbilityRegistry**: Stores and provides lookup for ability definitions. Validates uniqueness and provides query methods.
- **AbilityLoader**: Static loader that reads ability definitions from JSON and populates the registry.
- **AbilitySystem**: Manages ability execution, cooldown validation, component evaluation, and command generation. Uses SimulationContext for cooldown timing. Never deals damage directly. Never modifies HP. Never updates UI.
- **MatchFlowSystem**: Manages match lifecycle (state transitions, countdown, pause/resume, victory/defeat detection). Evaluates pluggable victory conditions from JSON. Uses SimulationContext for time. Pauses simulation during non-RUNNING states. Never modifies gameplay directly.
- **NexusSystem**: Manages base HP for each team. Provides damage_nexus() API. Emits nexus_damaged and nexus_destroyed events. Read by MatchFlowSystem for victory evaluation.

### Abilities Layer

Runtime ability state and component-based behavior.

- **AbilityInstance**: Runtime ability activation object. Stores instance_id, definition, owner, runtime_state, executed_components, generated_commands. Records execution details for debug purposes.
- **AbilityComponent**: Base interface for ability behavior components. Defines execute() method that returns GameCommand array. Components are composed to create ability behaviors.
- **ApplyEffectComponent**: Delegates to EffectSystem.apply_effect(). Reuses existing effect infrastructure.
- **SpawnProjectileComponent**: Delegates to ProjectileFactory.create_projectile(). Reuses existing projectile infrastructure.
- **GenerateCommandComponent**: Creates GameCommand objects for CommandDispatcher dispatch.

### Pipelines Layer

Ability execution pipeline abstraction.

- **AbilityPipeline**: Ordered list of AbilityPipelineNode objects. Created from JSON or auto-migrated from component arrays for backward compatibility.
- **AbilityPipelineNode**: Wraps a component execution or future node type (delay, condition, branch). Data-driven from JSON.
- **AbilityPipelineExecutor**: Executes pipeline nodes sequentially. Creates components from node data, collects GameCommand results.

### Conditions Layer

Pluggable match victory/defeat conditions.

- **MatchCondition**: Base interface for match conditions. Defines `check(context) -> bool` and `get_description() -> String`.
- **DestroyEnemyNexusCondition**: Checks if enemy nexus HP <= 0.
- **DestroyPlayerNexusCondition**: Checks if player nexus HP <= 0.
- **TimeLimitCondition**: Checks if elapsed match time >= configured limit.

### AI Decision Engine

AI layers for perception, evaluation, decision-making, and command generation. AI uses the same Commands as the player.

- **WorldState**: Read-only data snapshot that the AI uses to perceive the world. Contains friendly/enemy units, resources, available cards, ability cooldowns, nexus HP ratios, match state, battlefield dimensions, affinity distribution. Populated by PerceptionSystem.
- **PerceptionSystem**: Reads from existing game systems (SpatialQuerySystem, EconomySystem, NexusSystem, AbilitySystem) and produces a WorldState snapshot. Never inspects UI. Never modifies game state.
- **EvaluationSystem**: Calculates weighted scores for possible actions using personality evaluation_weights. Evaluates: Spawn Unit (card stats, strategic need, affinity preference), Use Ability (strategic need), Save Resources (resource ratio, strategy).
- **DecisionSystem**: Selects the highest-scoring evaluation result. Returns null if all scores are zero or negative.
- **AICommandGenerator**: Converts a decision into a gameplay Command (PlayCardCommand or AbilityCommand). Calculates spawn/target positions. Uses same command creation as the player.
- **AIDecisionEngine**: Orchestrates the decision cycle (Perception -> Evaluation -> Decision -> Command Generation) on a 1.5s interval. Emits ai_decision_started, ai_decision_finished, ai_command_generated events.
- **AIRegistry**: Stores AI personalities by ID. Validates uniqueness.
- **AILoader**: Static loader that reads AI personalities from JSON and populates the registry.
- **AIEvaluationResult**: Data container for evaluation results: action_type (spawn_unit, use_ability, save_resources), score, data dictionary.
- **AIDebugData**: Debug data for AI UI: personality info, evaluation scores, chosen action, generated command, resource reserve.

### Replay Layer

Deterministic replay infrastructure for recording, playback, and validation.

- **ReplayDefinition**: Serializable replay data container. Stores format_version, engine_version, content_version, game_mode_id, random_seed, initial_snapshot, command_log, final_tick, metadata.
- **ReplayRecorder**: Records gameplay commands via CommandLog. Supports checkpoints at configurable intervals. Creates ReplayDefinition on stop.
- **ReplayPlayer**: Loads replay, provides initial snapshot and seed. Advances tick-by-tick returning commands for each tick. Does not duplicate gameplay logic.
- **ReplayValidator**: Compares expected vs actual MatchSnapshots. Identifies first divergence with tick, entity, expected/actual values, and responsible system.
- **StateHasher**: Deterministic FNV-1a-style hash of gameplay state. Hashes tick, match state, nexus HP, unit positions/HP/state, economy values. Excludes non-deterministic data.

### Schema Layer

Schema versioning infrastructure for content compatibility.

- **SchemaVersion**: Semantic version (major.minor.patch) with compatibility checking. Major version must match, minor must be >= for compatibility.
- **SchemaValidator**: Validates JSON files against current schema version. Reports missing or incompatible schema_version fields.
- **ContentMigrationRegistry**: Registry for future schema migrations. Supports migration paths between versions.
- **ContentVersion**: Identifies exact content version used for a replay. Replays refuse to run with incompatible content versions.

### Factories Layer

Object creation logic.

- **UnitFactory**: Creates UnitInstance from PackedScene and initializes with UnitDefinition.
- **ProjectileFactory**: Creates ProjectileInstance and initializes with ProjectileDefinition. Supports optional debug mode.

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
ProjectileFactory    --[projectile_spawned]--> ProjectileSystem
ProjectileSystem     --[projectile_moved]----> (future listeners)
CollisionSystem      --[projectile_collided]-> (future listeners)
ProjectileSystem     --[projectile_destroyed]> (future listeners)
EffectSystem         --[effect_applied]-------> UnitVisualComponent, Debug UI
EffectSystem         --[effect_removed]-------> UnitVisualComponent, Debug UI
EffectSystem         --[effect_expired]-------> UnitVisualComponent, Debug UI
EffectSystem         --[effect_refreshed]-----> UnitVisualComponent, Debug UI
EffectSystem         --[effect_stack_changed]-> UnitVisualComponent, Debug UI
AbilitySystem        --[ability_started]-------> Debug UI
AbilitySystem        --[ability_finished]------> Debug UI
AbilitySystem        --[ability_cooldown_started] Ability UI
AbilitySystem        --[ability_ready]---------> Ability UI
MatchFlowSystem      --[match_started]---------> BattleScene
MatchFlowSystem      --[match_paused]----------> BattleScene
MatchFlowSystem      --[match_resumed]---------> BattleScene
MatchFlowSystem      --[match_finished]--------> BattleScene
MatchFlowSystem      --[victory]---------------> BattleScene
MatchFlowSystem      --[defeat]----------------> BattleScene
MatchFlowSystem      --[draw]------------------> BattleScene
MatchFlowSystem      --[countdown_started]-----> BattleScene
NexusSystem          --[nexus_damaged]---------> BattleScene
NexusSystem          --[nexus_destroyed]-------> MatchFlowSystem
AIDecisionEngine     --[ai_decision_started]----> Debug UI
AIDecisionEngine     --[ai_decision_finished]---> Debug UI
AIDecisionEngine     --[ai_command_generated]---> Debug UI
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

### Command Execution Flow

```
Player Input / AI Decision Engine
  -> Create GameCommand (immutable request)
  -> CommandDispatcher.dispatch(command)
     -> Route to appropriate system
     -> System executes command
     -> System produces GameAction (if applicable)
  -> EventBus broadcasts GameAction
  -> Listeners react to GameAction
```

### AI Decision Flow

```
AIDecisionEngine.update(delta)
  -> Timer reaches DECISION_INTERVAL (1.5s)
  -> EventBus.ai_decision_started.emit(personality_id)
  -> PerceptionSystem.perceive(team)
     -> Read SpatialQuerySystem (units, formations)
     -> Read EconomySystem (resources)
     -> Read NexusSystem (nexus HP)
     -> Read AbilitySystem (cooldowns)
     -> Read StageDefinition (battlefield)
     -> Produce WorldState
  -> EvaluationSystem.evaluate(world_state)
     -> Score spawn options (card stats + strategic need + personality weights)
     -> Score ability options (strategic need + personality weights)
     -> Score save resources (resource ratio + personality strategy)
     -> Return Array[AIEvaluationResult]
  -> DecisionSystem.decide(evaluations)
     -> Select highest score
     -> Return AIEvaluationResult or null
  -> AICommandGenerator.generate(decision, team)
     -> For spawn_unit: Create PlayCardCommand
     -> For use_ability: Create AbilityCommand
  -> CommandDispatcher.dispatch(command)
     -> Same pipeline as player
  -> EventBus.ai_command_generated.emit(command, personality_id)
  -> EventBus.ai_decision_finished.emit(personality_id, action_type)
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
              -> RangedAttackModel: 
                 1. Resolve ProjectileDefinition from attacker.definition.projectile_id
                 2. ProjectileFactory.create_projectile() -> ProjectileInstance
                 3. EventBus.projectile_spawned.emit(projectile)
                 4. Return DamageAction.create(0, attacker, target) (damage applied later by CollisionSystem)
        -> EventBus.attack_finished.emit(action)
  -> CombatSystem._apply_damage_action(action)
     -> For melee: target.take_damage(action.damage)
     -> For ranged: action.damage is 0, no immediate damage
     -> EventBus.action_performed.emit(action)
```

### Projectile Lifecycle

```
1. Ranged unit's attack timer expires
2. CombatSystem creates AttackCommand
3. CommandDispatcher.dispatch(command)
4. AttackSystem.execute() calls RangedAttackModel.execute()
5. RangedAttackModel resolves ProjectileDefinition
6. ProjectileFactory.create_projectile()
   a. Create ProjectileInstance
   b. Initialize with position, direction, speed, owner, target
   c. EventBus.projectile_spawned emitted
7. ProjectileSystem registers projectile
8. ProjectileSystem._physics_process() runs each frame
   a. Update projectile movement using SimulationContext.delta_time
   b. EventBus.projectile_moved emitted
   c. Check if projectile has reached target or expired
9. CollisionSystem._physics_process() runs each frame
   a. Check projectile collisions with units
   b. If collision detected:
      i. EventBus.projectile_collided.emit(projectile, target)
      ii. Create DamageAction with projectile damage
      iii. EventBus.action_performed.emit(action)
      iv. CombatSystem consumes DamageAction, applies HP
      v. EventBus.projectile_destroyed.emit(projectile)
      vi. Remove projectile from scene
10. If projectile expires without collision:
    a. EventBus.projectile_destroyed.emit(projectile)
    b. Remove projectile from scene
```

### Per-Frame Update Order

```
_physics_process(delta):
  1. BattleScene._physics_process()
     -> SimulationContext.update(delta)
     -> _update_ai(delta)
        -> AIDecisionEngine.update(delta)
           -> PerceptionSystem -> EvaluationSystem -> DecisionSystem -> AICommandGenerator
           -> PlayCardCommand / AbilityCommand -> CommandDispatcher
     -> _update_debug_panel()
     -> _update_resource_panel()
     -> _update_card_affordability()
     -> _update_ai_debug_panel()

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
            -> For melee units:
               -> _update_attack_timer()
                  -> AttackCommand -> CommandDispatcher
                     -> AttackSystem.execute()
                        -> AttackModelRegistry.resolve()
                        -> MeleeAttackModel.execute() -> DamageAction
                  -> _apply_damage_action()
                     -> AffinityRuleSystem.get_attack_modifiers() -> CombatModifierCollection
                     -> Apply modifiers to base damage
                     -> target.take_damage(final_damage)
                     -> EventBus.action_performed.emit(action)
            -> For ranged units:
               -> _update_attack_timer()
                  -> AttackCommand -> CommandDispatcher
                     -> AttackSystem.execute()
                        -> AttackModelRegistry.resolve()
                        -> RangedAttackModel.execute() -> DamageAction(0)
                           -> ProjectileFactory.create_projectile()
                  -> _apply_damage_action()
                     -> action.damage is 0, no immediate damage

  5. ProjectileSystem._physics_process()
     -> _update_all_projectiles()
        -> For each projectile:
           -> projectile.update_movement(SimulationContext.delta_time)
           -> EventBus.projectile_moved.emit(projectile)
     -> _cleanup_expired_projectiles()
        -> Remove expired projectiles
        -> EventBus.projectile_destroyed.emit(projectile)

  6. CollisionSystem._physics_process()
     -> _check_projectile_collisions()
        -> For each projectile:
           -> If projectile.has_reached_target():
              -> _handle_projectile_collision(projectile)
                 -> Create DamageAction
                 -> EventBus.action_performed.emit(action)
                 -> EventBus.projectile_destroyed.emit(projectile)

  7. EconomySystem._physics_process()
     -> Regenerate resources using SimulationContext.delta_time

  8. UnitInstance._physics_process() (each unit)
     -> _validate_target()
     -> State machine processing
```
