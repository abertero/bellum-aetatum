# ADR-013: Ability Composition Engine

## Status

Accepted.

## Context

The game requires a system for abilities (special actions like Battle Cry, Arrow Volley) that can be composed from reusable building blocks. Without a dedicated Ability system:
- Each ability would require custom code (one class per ability)
- No data-driven ability configuration
- No reusable ability infrastructure
- Violates Open/Closed Principle

The architecture already provides:
- EffectSystem for applying buffs/debuffs via EffectComponent composition
- ProjectileFactory for spawning projectiles
- CommandDispatcher for routing commands to systems
- EventBus for decoupled communication
- Definition/Registry/Loader pattern for data management
- SimulationContext for time management

## Decision

Introduce an Ability Composition Engine where abilities are compositions of reusable AbilityComponent objects, defined entirely in JSON.

### AbilityDefinition
Pure data container loaded from JSON. Contains: id, display_name, description, icon, cooldown, activation, components, metadata. Components define ability behavior through composition.

### AbilityInstance
Runtime object (RefCounted) representing a single ability activation. Contains: instance_id, definition, owner, runtime_state, metadata, executed_components, generated_commands. Records what happened during execution for debug purposes.

### AbilityComponent
Base interface for ability behavior components. Defines `execute(caster, target, context) -> Array[GameCommand]`. Components are composed to create ability behaviors.

### Initial Components
- **ApplyEffectComponent**: Delegates to EffectSystem.apply_effect(). Reuses existing effect infrastructure.
- **SpawnProjectileComponent**: Delegates to ProjectileFactory.create_projectile(). Reuses existing projectile infrastructure.
- **GenerateCommandComponent**: Creates GameCommand objects for CommandDispatcher.

### AbilitySystem
Node-based system that manages ability execution and cooldowns. Responsibilities: validate cooldown, evaluate components, produce commands, dispatch commands, track cooldowns using SimulationContext. Never deals damage directly. Never modifies HP. Never updates UI.

### AbilityRegistry / AbilityLoader
Follow the established Definition/Registry/Loader pattern. AbilityRegistry stores definitions by ID. AbilityLoader reads from `data/abilities.json`.

### Cooldown
Cooldowns tracked per owner per ability using SimulationContext.delta_time. AbilitySystem emits ability_cooldown_started and ability_ready signals.

### Targeting
Reuses existing TargetingSystem. Abilities receive target from caster.current_target. No targeting logic duplication.

### Initial Abilities
- **Battle Cry**: ApplyEffectComponent applies "strength" effect to caster. Cooldown: 15s.
- **Arrow Volley**: SpawnProjectileComponent spawns "arrow_basic" projectile at target. Cooldown: 8s.

### Execution Flow
```
1. AbilitySystem.execute_ability(ability_id, caster, target)
2. Check cooldown -> if on cooldown, return false
3. Start cooldown -> emit ability_cooldown_started
4. Create AbilityInstance from definition
5. For each component in definition.components:
   a. Create AbilityComponent from type string
   b. component.execute(caster, target, context)
   c. Record executed component type
   d. Collect returned commands
6. Dispatch commands through CommandDispatcher
7. Emit ability_finished
```

## Alternatives Considered

### 1. One class per ability
Each ability as a separate class (BattleCryAbility, ArrowVolleyAbility). Rejected because it violates OCP. Adding abilities would require code changes. JSON composition is more flexible.

### 2. Abilities as Effects
Abilities could be a special type of Effect. Rejected because abilities are one-shot activations while effects are ongoing states. Different lifecycles require different systems.

### 3. Abilities owned by UnitInstance
UnitInstance could manage its own abilities. Rejected because it violates SRP. AbilitySystem should own execution and cooldowns, similar to how EffectSystem owns effect lifecycle.

### 4. Direct damage in AbilitySystem
AbilitySystem could deal damage directly. Rejected because it violates the architectural principle that CombatSystem is the only system that modifies HP. Abilities produce Commands which flow through existing systems.

### 5. Separate targeting system for abilities
Abilities could have their own targeting logic. Rejected because TargetingSystem already handles target assignment. Abilities reuse caster.current_target.

## Consequences

### Positive
- Abilities are fully data-driven via JSON
- New abilities require only JSON configuration, no code changes
- New ability behaviors added by creating new AbilityComponent subclasses
- Existing infrastructure (EffectSystem, ProjectileFactory) fully reused
- AbilitySystem never deals damage, modifies HP, or updates UI
- Cooldowns use SimulationContext for consistent timing
- Debug panel shows executed components and generated commands
- UI displays ability icons, cooldowns, and descriptions from AbilityDefinition

### Negative
- AbilitySystem adds another system to initialize and wire up
- AbilityInstance objects add memory overhead per activation
- battle_scene.gd continues to grow (coordinator pattern)

### Risks
- AbilitySystem must be initialized after EffectSystem and ProjectileSystem
- Components must handle null/invalid targets gracefully
- Cooldown tracking must clean up references to freed units

## Migration Strategy

No migration needed. This is a new system with no breaking changes to existing code.

Existing systems remain unchanged:
- CombatSystem: No modifications
- EffectSystem: No modifications (called by ApplyEffectComponent)
- ProjectileFactory: No modifications (called by SpawnProjectileComponent)
- CommandDispatcher: No modifications (receives commands from GenerateCommandComponent)
- TargetingSystem: No modifications (abilities reuse current_target)

## Files Created

| File | Purpose |
|---|---|
| `definitions/AbilityDefinition.gd` | Data container for ability properties |
| `abilities/AbilityInstance.gd` | Runtime state for ability activation |
| `abilities/AbilityComponent.gd` | Base component interface |
| `abilities/ApplyEffectComponent.gd` | Applies effects via EffectSystem |
| `abilities/SpawnProjectileComponent.gd` | Spawns projectiles via ProjectileFactory |
| `abilities/GenerateCommandComponent.gd` | Produces GameCommand objects |
| `systems/AbilityRegistry.gd` | Stores and provides lookup for ability definitions |
| `systems/AbilityLoader.gd` | Loads ability definitions from JSON |
| `systems/AbilitySystem.gd` | Ability execution, cooldown, component evaluation |
| `data/abilities.json` | Ability definitions (Battle Cry, Arrow Volley) |

## Files Modified

| File | Changes |
|---|---|
| `core/EventBus.gd` | Added 5 ability signals |
| `scenes/battle_scene.gd` | Setup AbilitySystem, ability UI panel, ability debug panel, demo triggers |
