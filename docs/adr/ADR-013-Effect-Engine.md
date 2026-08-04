# ADR-013: Effect Engine

## Status

Accepted.

## Context

The game requires a generic system for gameplay effects (buffs, debuffs, status conditions) that modify unit behavior during combat. Previous milestones established the CombatModifier and CombatModifierCollection abstractions specifically designed to support multiple modifier sources (affinity rules, terrain, weather, abilities, equipment, status effects).

Without a dedicated Effect Engine:
- Effects would need to be hardcoded into CombatSystem
- Each effect type would require custom code
- No data-driven effect configuration
- No reusable effect infrastructure
- No stacking, duration, or refresh mechanics

The architecture already provides:
- CombatModifier/CombatModifierCollection for modifier application
- EventBus for decoupled communication
- Data-driven JSON loading patterns
- Definition/Registry/Loader pattern for data management

## Decision

Introduce a generic Effect Engine with the following components:

### EffectDefinition
Pure data container loaded from JSON. Contains: id, display_name, description, icon, duration, stacking_policy, refresh_policy, visual_hint, triggers, modifiers, metadata. Future fields can be added without code changes.

### EffectInstance
Runtime object (RefCounted) representing an active effect on a unit. Contains: instance_id, definition, source, owner, remaining_duration, stack_count, state, metadata. Generates CombatModifier objects from its definition's modifier data, scaled by stack_count.

### EffectSystem
Node-based system that owns the effect lifecycle. Responsibilities: create effects, destroy expired effects, update durations, handle stacking, refresh durations, emit events, dispatch triggers. Never modifies HP directly. Never updates UI.

### EffectRegistry / EffectLoader
Follow the established Definition/Registry/Loader pattern. EffectRegistry stores definitions by ID. EffectLoader reads from `data/effects.json`.

### Stacking Policies
- NO_STACK: Reject duplicate application
- STACK: Increment stack_count, each stack adds full modifier value
- REFRESH_DURATION: Reset duration to full, don't stack
- REPLACE: Remove old effect, apply new one

### Trigger Infrastructure
Effects can declare triggers (OnApply, OnRemove, OnTurn, OnAttack, OnReceiveDamage, OnDeath). EffectSystem subscribes to EventBus signals and dispatches to affected effects. Only infrastructure is implemented; no complex behaviors.

### CombatModifier Integration
EffectSystem provides `get_attack_modifiers(unit)` and `get_defense_modifiers(unit)` methods. CombatSystem queries EffectSystem and appends effect modifiers to the same CombatModifierCollection used by AffinityRuleSystem. CombatSystem's core logic (timers, commands, HP modification) remains unchanged.

### Initial Effects
Only two effects are implemented:
- Strength: +10% attack (MULTIPLY 1.1 on attack)
- Shield: -10% incoming damage (MULTIPLY 0.9 on defense)

## Alternatives Considered

### 1. Effects as Nodes
Effects could be Node objects in the scene tree. Rejected because effects are data-driven gameplay objects, not spatial entities. RefCounted is more appropriate and avoids scene tree overhead.

### 2. Effects owned by UnitInstance
UnitInstance could manage its own effects. Rejected because it violates SRP. EffectSystem should own the lifecycle, similar to how EconomySystem owns resources and ProjectileSystem owns projectiles.

### 3. Hardcoded effect behaviors
Each effect type could have custom code in CombatSystem. Rejected because it violates OCP and data-driven principles. All effect data comes from JSON.

### 4. Separate modifier collection per effect source
CombatSystem could maintain separate collections for affinity, effect, terrain, etc. Rejected because CombatModifierCollection already supports multiple modifiers from any source. A single unified collection is simpler and more flexible.

### 5. Polling for trigger events
EffectSystem could poll for trigger conditions each frame. Rejected because EventBus provides efficient event-driven communication. Polling wastes CPU and introduces latency.

## Consequences

### Positive
- Effects are fully data-driven via JSON
- New effects require only JSON configuration, no code changes
- CombatSystem remains generic and unaware of specific effect types
- Stacking, duration, and refresh mechanics are reusable
- Trigger infrastructure enables future complex behaviors
- Effect modifiers integrate seamlessly with existing CombatModifier system
- UI displays effect icons from EffectDefinition data (no hardcoded icons)
- Debug panel shows active effects, durations, stacks, and modifiers

### Negative
- EffectSystem adds another system to initialize and wire up
- EffectInstance objects add memory overhead per active effect
- Trigger dispatch adds event handling complexity
- battle_scene.gd exceeds 250 lines (coordinator pattern)

### Risks
- EffectSystem must be initialized before CombatSystem
- Effect modifiers must use appropriate priorities to avoid conflicts with affinity modifiers
- Stacking policies must be carefully designed to avoid unintended interactions

## Migration Strategy

No migration needed. This is a new system with no breaking changes to existing code.

CombatSystem's `initialize()` signature changed to accept an optional `EffectSystem` parameter (defaults to null for backward compatibility). The `_calculate_final_damage()` method was updated to query EffectSystem for additional modifiers, but the core combat flow is unchanged.

## Files Created

| File | Purpose |
|---|---|
| `definitions/EffectDefinition.gd` | Data container for effect properties |
| `systems/EffectRegistry.gd` | Stores and provides lookup for effect definitions |
| `systems/EffectLoader.gd` | Loads effect definitions from JSON |
| `effects/EffectInstance.gd` | Runtime effect state and modifier generation |
| `systems/EffectSystem.gd` | Effect lifecycle management |
| `data/effects.json` | Effect definitions (Strength, Shield) |

## Files Modified

| File | Changes |
|---|---|
| `core/EventBus.gd` | Added 5 effect signals |
| `systems/CombatSystem.gd` | Added EffectSystem integration for modifier collection |
| `entities/UnitVisualComponent.gd` | Added effect icon display with tooltips |
| `scenes/battle_scene.gd` | Setup EffectSystem, effect debug panel, demo effect application |
