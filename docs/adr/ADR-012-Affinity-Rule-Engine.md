# ADR-012: Affinity Rule Engine

## Status

Accepted

## Context

The game previously had no affinity system, meaning all units dealt and received damage uniformly regardless of their elemental type. This limited strategic depth and made combat less interesting.

The existing architecture had several constraints:

1. **CombatSystem responsibility**: CombatSystem was the only system that could modify HP, which is correct for SRP.
2. **No affinity infrastructure**: There was no way to represent elemental affinities or their relationships.
3. **Hardcoded rules risk**: Implementing affinity rules directly in CombatSystem would violate SRP and make the system harder to maintain.
4. **Extensibility requirement**: Future combat modifiers (terrain, weather, abilities, equipment, status effects) need a generic way to modify combat calculations.

The challenge was to introduce affinities without violating the existing architectural principles:
- CombatSystem must remain the only system that modifies HP
- All combat modifiers must flow through a generic system
- The architecture must remain data-driven
- Future systems must be able to append modifiers without modifying CombatSystem

## Decision

Introduce an Affinity Rule Engine that separates affinity definitions, rules, and combat modifiers into distinct systems, while maintaining CombatSystem as the sole HP modifier through a generic CombatModifierCollection pattern.

### Core Components

1. **AffinityDefinition**: Pure data container loaded from JSON. Defines affinity properties (id, display_name, description, primary_color, icon, background).

2. **AffinityRegistry**: Stores and provides lookup for affinity definitions. Validates uniqueness and provides query methods.

3. **AffinityLoader**: Static loader that reads affinity definitions from JSON and populates the registry.

4. **CombatModifier**: Represents a single combat modification with id, source, priority, operation (MULTIPLY, ADD, OVERRIDE, MIN, MAX), value, description, and metadata.

5. **CombatModifierCollection**: Contains multiple CombatModifier objects and provides methods to apply them in priority order to a base value.

6. **AffinityRuleSystem**: Loads affinity rules from JSON, resolves attack and defense modifiers based on attacker/defender affinity pairs, and returns CombatModifierCollection objects.

### Architecture Flow

```
CombatSystem detects attack
  ↓
CombatSystem requests CombatModifierCollection from AffinityRuleSystem
  ↓
AffinityRuleSystem resolves attacker and defender affinities
  ↓
AffinityRuleSystem looks up relationship in rules
  ↓
AffinityRuleSystem creates CombatModifier objects
  ↓
AffinityRuleSystem returns CombatModifierCollection
  ↓
CombatSystem applies modifiers to base damage
  ↓
CombatSystem applies final damage to target
```

### Key Design Decisions

1. **CombatModifierCollection pattern**: All combat modifiers flow through this generic collection, allowing any system (AffinityRuleSystem, TerrainSystem, WeatherSystem, etc.) to append modifiers without modifying CombatSystem.

2. **Priority-based application**: Modifiers are applied in priority order, allowing fine-grained control over modifier stacking.

3. **Multiple operation types**: Support for MULTIPLY, ADD, OVERRIDE, MIN, MAX operations provides flexibility for different modifier types.

4. **Data-driven rules**: All affinity relationships and default values are loaded from JSON, making balancing and iteration easy.

5. **No affinity knowledge in CombatSystem**: CombatSystem only knows about CombatModifierCollection, not about specific affinity types or rules.

### Data Configuration

**affinities.json**:
```json
{
  "affinities": [
    {
      "id": "ignis",
      "display_name": "Ignis",
      "description": "Fire affinity",
      "primary_color": "#FF4500",
      "icon": "res://assets/icons/ignis.png",
      "background": "res://assets/backgrounds/ignis_bg.png"
    }
  ]
}
```

**affinity_rules.json**:
```json
{
  "default_values": {
    "attack_advantage": 1.2,
    "attack_disadvantage": 0.8,
    "defense_advantage": 0.8,
    "defense_disadvantage": 1.2
  },
  "relationships": [
    {
      "attacker": "ignis",
      "defender": "terra",
      "attack_modifier": 1.2,
      "defense_modifier": 0.8
    }
  ]
}
```

**cards.json** (affinity reference):
```json
{
  "id": "roman_legionary_001",
  "stats": {
    "affinity_id": "ignis"
  }
}
```

## Alternatives Considered

### Alternative 1: Hardcoded Affinity Logic in CombatSystem

Implement affinity checks directly in CombatSystem using switch statements or if-else chains.

**Pros**:
- Simpler implementation
- No additional systems needed

**Cons**:
- Violates SRP (CombatSystem would have affinity knowledge)
- Not data-driven
- Hard to maintain and extend
- Cannot support future modifier systems

**Why Rejected**: Violates core architectural principles and makes the system inflexible for future features.

### Alternative 2: Affinity as AttackModel Subclass

Create AffinityAttackModel that extends AttackModel and handles affinity logic.

**Pros**:
- Reuses existing AttackModel pattern
- Clear separation

**Cons**:
- Duplicates affinity logic across models
- Cannot support multiple modifier sources
- Violates SRP (AttackModel would have affinity knowledge)

**Why Rejected**: AttackModel should focus on damage calculation, not affinity rules. The CombatModifierCollection pattern is more flexible.

### Alternative 3: EventBus for Affinity Modifiers

Use EventBus signals to request and receive affinity modifiers.

**Pros**:
- Fully decoupled

**Cons**:
- Asynchronous modifier collection is complex
- Need to wait for responses
- Harder to track modifier application order
- Mixes request/response with broadcast patterns

**Why Rejected**: Modifier collection should be synchronous. CombatSystem needs immediate answers before applying damage.

### Alternative 4: Single Float Return from AffinityRuleSystem

AffinityRuleSystem returns a single multiplier float instead of CombatModifierCollection.

**Pros**:
- Simpler API
- Less overhead

**Cons**:
- Cannot support multiple modifier sources
- Cannot track modifier history
- Cannot support complex stacking rules
- Not extensible for future systems

**Why Rejected**: The CombatModifierCollection pattern is essential for supporting multiple modifier sources (terrain, weather, abilities, etc.) in the future.

### Alternative 5: Affinity as UnitInstance Component

Add affinity as a component of UnitInstance that handles affinity logic.

**Pros**:
- Close to unit data
- Easy to access

**Cons**:
- Violates SRP (UnitInstance would have affinity rule knowledge)
- Duplicates affinity logic across units
- Cannot support global affinity rules

**Why Rejected**: Affinity rules are global and should be centralized in AffinityRuleSystem, not distributed across units.

## Consequences

### Positive

1. **Strategic depth**: Affinities add a layer of strategy to unit selection and combat.

2. **Data-driven**: All affinity properties and rules are loaded from JSON, making balancing easy.

3. **Extensible modifier system**: CombatModifierCollection pattern supports future modifier systems (terrain, weather, abilities, equipment, status effects).

4. **Maintains architectural principles**: CombatSystem remains the only system that modifies HP, all modifiers flow through generic collection.

5. **Visual feedback**: UI automatically displays affinity information from AffinityDefinition.

6. **Debug support**: Debug panel shows affinity modifiers and final damage calculations.

7. **Priority-based stacking**: Modifiers can be applied in specific order for complex interactions.

8. **Multiple operation types**: Support for various modifier operations provides flexibility.

9. **No affinity knowledge in CombatSystem**: CombatSystem is completely generic and doesn't know about specific affinity types.

10. **Future-proof**: Architecture supports adding new modifier systems without modifying existing code.

### Negative

1. **Additional complexity**: Three new systems (AffinityRegistry, AffinityLoader, AffinityRuleSystem) and two new data structures (CombatModifier, CombatModifierCollection) add complexity.

2. **Performance overhead**: Modifier collection and application add per-combat overhead. However, this is minimal for typical battlefield sizes.

3. **Data management**: Requires maintaining affinity definitions and rules in JSON files.

4. **Learning curve**: New developers must understand the CombatModifierCollection pattern and priority-based application.

5. **Debugging complexity**: Tracking modifier application order and interactions can be complex.

### Neutral

1. **No affinity knowledge in CombatSystem**: This is both a positive (maintains SRP) and neutral (CombatSystem is less self-contained).

2. **Event-driven debug**: Affinity debug information is emitted via EventBus, which adds another signal to track.

3. **UI coupling**: Card buttons now depend on AffinityRegistry for display, but this is appropriate since UI should render definitions.

## Migration Strategy

### Phase 1: Foundation (Current)

- Add AffinityDefinition, AffinityRegistry, AffinityLoader
- Add CombatModifier, CombatModifierCollection
- Add AffinityRuleSystem
- Create affinity JSON definitions and rules
- Update UnitDefinition to include affinity_id
- Update cards.json with affinity references
- Update CombatSystem to use CombatModifierCollection
- Update UI to display affinity information
- Add debug display for affinity modifiers

### Phase 2: Additional Modifier Systems (Future)

- Add TerrainSystem that appends terrain modifiers to CombatModifierCollection
- Add WeatherSystem that appends weather modifiers
- Add AbilitySystem that appends ability modifiers
- Add EquipmentSystem that appends equipment modifiers
- Add StatusEffectSystem that appends status effect modifiers

### Phase 3: Advanced Features (Future)

- Implement modifier stacking rules (diminishing returns, caps, etc.)
- Add modifier visualization (show all active modifiers in UI)
- Implement modifier history tracking (for replay and analytics)
- Add modifier-based achievements and statistics

### Phase 4: Optimization (Future)

- Cache modifier collections for common affinity pairs
- Optimize modifier application for large numbers of modifiers
- Add modifier pooling for frequently created modifiers

## Relationship to Action Framework

The Affinity Rule Engine complements the Action Framework:

| Aspect | Action Framework | Affinity Rule Engine |
|--------|------------------|----------------------|
| **Purpose** | Represent outcomes | Provide modifiers |
| **Timing** | After execution | Before execution |
| **Flow** | System -> EventBus -> Listeners | System -> ModifierCollection -> System |
| **Examples** | DamageAction, HealAction | CombatModifier, CombatModifierCollection |

**Flow**:
```
CombatSystem -> AffinityRuleSystem -> CombatModifierCollection -> CombatSystem -> DamageAction
```

## Future Modifier Types

The CombatModifierCollection pattern supports future modifier types without modification:

- **Terrain modifiers**: Forest defense bonus, mountain attack penalty
- **Weather modifiers**: Rain ranged penalty, snow speed penalty
- **Ability modifiers**: Buffs, debuffs, special attacks
- **Equipment modifiers**: Weapon bonuses, armor bonuses
- **Status effect modifiers**: Poison damage, stun effects
- **Legendary modifiers**: Special legendary unit bonuses

Each modifier type:
1. Creates CombatModifier objects with appropriate operation and value
2. Appends to CombatModifierCollection
3. CombatSystem applies all modifiers in priority order

## Verification

Gameplay behavior changes:

- Units now deal modified damage based on affinity relationships
- Affinity advantages provide 20% bonus damage
- Affinity disadvantages provide 20% penalty damage
- Cards display affinity information in UI
- Debug panel shows affinity modifier calculations

Existing gameplay preserved:

- CombatSystem remains the only system that modifies HP
- Unit spawning unchanged
- Formation unchanged
- Targeting unchanged
- Death unchanged
- Movement unchanged
- Economy unchanged
- Projectile system unchanged

Architectural principles maintained:

- CombatSystem remains completely generic
- All modifiers flow through CombatModifierCollection
- AffinityRuleSystem provides modifiers, doesn't apply them
- Data-driven configuration
- Event-driven debug
