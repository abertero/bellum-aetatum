# ADR-012: Modular Effect Engine

## Status

Accepted

## Context

The game requires a flexible system for applying temporary gameplay effects to units (buffs, debuffs, status conditions). Effects need to:

- Modify combat statistics (attack, defense, speed)
- Have configurable durations
- Support stacking policies (no stack, refresh duration, replace)
- Be data-driven via JSON configuration
- Be extensible for future effect types (periodic damage, triggers, movement modifiers, etc.)

The previous monolithic approach hardcoded effect logic into EffectInstance, making it difficult to add new effect behaviors without modifying core code.

## Decision

Implement a **component-based Effect Engine** where effects are compositions of reusable EffectComponent objects.

### Architecture

```
EffectDefinition (JSON data)
  ↓
EffectInstance (runtime state)
  ↓
EffectComponent[] (behavior modules)
  ├─ DurationComponent (time management)
  ├─ CombatModifierComponent (stat modification)
  └─ [Future: PeriodicDamageComponent, TriggerComponent, etc.]
```

### Key Components

1. **EffectDefinition**: Pure data container loaded from JSON. Contains:
   - id, display_name, description, icon
   - stacking_policy, visual_hint
   - components: Array of component configurations
   - metadata

2. **EffectInstance**: Runtime object that:
   - Stores instance_id, owner, source, stack_count
   - Maintains runtime_state Dictionary for component-specific data
   - Instantiates EffectComponent objects from definition
   - Delegates behavior to components

3. **EffectComponent**: Base interface (RefCounted) with:
   - `update(delta, instance)` - per-frame logic
   - `get_modifiers(instance)` - generate CombatModifiers
   - `is_expired(instance)` - check expiration
   - Component-specific methods

4. **DurationComponent**: Manages:
   - remaining_time in runtime_state
   - expiration detection
   - refresh policy (REFRESH_DURATION, NO_REFRESH)

5. **CombatModifierComponent**: Generates:
   - CombatModifier objects from configuration
   - Scales values based on stack_count
   - Supports all operations (MULTIPLY, ADD, OVERRIDE, MIN, MAX)

### JSON Structure

```json
{
  "id": "strength",
  "display_name": "Strength",
  "stacking_policy": "STACK",
  "components": [
    {
      "type": "DurationComponent",
      "duration": 10.0,
      "refresh_policy": "REFRESH_DURATION"
    },
    {
      "type": "CombatModifierComponent",
      "modifiers": [
        {
          "target": "attack",
          "operation": "MULTIPLY",
          "value": 1.1,
          "priority": 100
        }
      ]
    }
  ]
}
```

## Alternatives Considered

### 1. Monolithic EffectInstance
**Approach**: All effect logic in EffectInstance with conditional branches.

**Pros**: Simpler initial implementation.

**Cons**: Violates Open/Closed Principle. Adding new effect types requires modifying EffectInstance. Difficult to test individual behaviors.

**Decision**: Rejected. Not extensible.

### 2. Inheritance-Based Effects
**Approach**: Base Effect class with subclasses (DurationEffect, ModifierEffect, etc.).

**Pros**: Clear separation of concerns.

**Cons**: Single inheritance limitation. Effects often need multiple behaviors (duration + modifier). Code duplication.

**Decision**: Rejected. Composition over inheritance.

### 3. Script-Based Effects
**Approach**: Each effect has a custom GDScript that implements behavior.

**Pros**: Maximum flexibility.

**Cons**: Requires scripting knowledge. Harder to data-drive. Security concerns with dynamic code execution.

**Decision**: Rejected. Too complex for data-driven design.

### 4. Entity-Component-System (ECS)
**Approach**: Full ECS architecture with entities, components, and systems.

**Pros**: Maximum performance and flexibility.

**Cons**: Overkill for current scope. Requires significant refactoring. Godot's node system already provides some ECS benefits.

**Decision**: Rejected. Component-based approach provides 80% of benefits with 20% of complexity.

## Consequences

### Positive

1. **Open/Closed Principle**: New effect behaviors added by creating new EffectComponent subclasses, not modifying existing code.

2. **Reusability**: Components can be mixed and matched. DurationComponent + CombatModifierComponent is a common pattern, but future effects can combine different components.

3. **Data-Driven**: All effect configuration in JSON. Designers can create new effects without code changes.

4. **Testability**: Each component can be tested in isolation.

5. **Extensibility**: Future components (PeriodicDamageComponent, TriggerComponent, MovementComponent) can be added without modifying EffectSystem or EffectInstance.

6. **Separation of Concerns**: EffectSystem manages lifecycle, EffectInstance manages state, EffectComponent manages behavior.

### Negative

1. **Complexity**: More classes and indirection than monolithic approach.

2. **Runtime Overhead**: Component instantiation and delegation adds minor overhead (negligible for current scope).

3. **Learning Curve**: Developers must understand component architecture.

### Risks

1. **Component Interaction**: Components may need to interact (e.g., DurationComponent affects CombatModifierComponent). Mitigated by shared runtime_state Dictionary.

2. **Performance**: Many simultaneous effects with many components could impact performance. Mitigated by keeping component count low (2-3 per effect).

## Migration Strategy

### Phase 1: Component Infrastructure (Current)
- Create EffectComponent base class
- Implement DurationComponent
- Implement CombatModifierComponent
- Refactor EffectDefinition to use components array
- Refactor EffectInstance to delegate to components
- Refactor EffectSystem to evaluate components

### Phase 2: Validation
- Implement Strength and Shield effects using component composition
- Verify CombatModifier integration
- Verify duration management
- Verify stacking policies

### Phase 3: Future Extensions
- Add PeriodicDamageComponent (poison, burn, bleed)
- Add TriggerComponent (on-attack, on-damage effects)
- Add MovementComponent (speed modifiers, immobilize)
- Add TargetFilterComponent (affect specific unit types)
- Add VisualComponent (particle effects, UI indicators)

## Verification

- ✅ Effects load correctly from JSON
- ✅ EffectComponents execute correctly
- ✅ CombatModifierComponent integrates with CombatModifierCollection
- ✅ CombatSystem remains unchanged (uses EffectSystem.get_modifiers())
- ✅ DurationComponent manages time via SimulationContext
- ✅ Stacking policies work correctly
- ✅ Runtime state is properly isolated per instance
- ✅ Engine supports creating future effects through composition

## Files Created

| File | Lines | Purpose |
|---|---|---|
| `effects/EffectComponent.gd` | 22 | Base component interface |
| `effects/DurationComponent.gd` | 54 | Time management component |
| `effects/CombatModifierComponent.gd` | 62 | Stat modification component |

## Files Modified

| File | Lines Changed | Reason |
|---|---|---|
| `definitions/EffectDefinition.gd` | -15, +10 | Use components array instead of inline modifiers/triggers |
| `effects/EffectInstance.gd` | -80, +95 | Delegate to components, use runtime_state |
| `systems/EffectSystem.gd` | -30, +25 | Evaluate components instead of inline logic |
| `systems/CombatSystem.gd` | -5, +5 | Use new EffectSystem.get_modifiers() API |
| `scenes/battle_scene.gd` | -5, +5 | Use new EffectInstance API for debug display |
| `data/effects.json` | Complete rewrite | Component-based structure |

## References

- [ADR-011: Affinity Rule Engine](./ADR-011-Affinity-Rule-Engine.md) - CombatModifier integration
- [Milestone 12: Effect Engine](../MILESTONES.md#milestone-12--effect-engine) - Implementation details
