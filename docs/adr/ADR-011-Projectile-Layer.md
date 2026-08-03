# ADR-011: Projectile Layer

## Status

Accepted

## Context

The game previously only supported melee combat, where units would engage in direct contact and apply damage immediately. This limitation prevented the implementation of ranged units (archers, mages, etc.) which are essential for a strategy game.

The existing architecture had several constraints:

1. **AttackModel contract**: The `AttackModel.execute()` method returns a `DamageAction`, implying immediate damage application.
2. **CombatSystem responsibility**: CombatSystem was the only system that could modify HP, which is correct for SRP.
3. **No projectile infrastructure**: There was no way to represent projectiles as first-class entities that travel over time.
4. **Timing mismatch**: Ranged attacks need travel time, but the existing attack pipeline was synchronous.

The challenge was to introduce projectiles without violating the existing architectural principles:
- CombatSystem must remain the only system that modifies HP
- Actions must flow through EventBus
- Systems must use SimulationContext for time-based updates
- The architecture must remain data-driven

## Decision

Introduce a Projectile Layer that separates projectile creation, movement, and collision detection into distinct systems, while reusing the existing Action Framework and maintaining CombatSystem as the sole HP modifier.

### Core Components

1. **ProjectileDefinition**: Pure data container loaded from JSON. Defines projectile properties (id, display_name, speed, max_range, damage, projectile_type, image).

2. **ProjectileInstance**: Runtime entity (Node2D) representing a projectile in flight. Owns position, direction, speed, owner, target, remaining_distance. Handles movement and collision detection. Supports optional debug rendering.

3. **ProjectileFactory**: Creates ProjectileInstance from ProjectileDefinition. Static factory with debug mode support.

4. **ProjectileSystem**: Manages projectile movement and lifecycle. Uses SimulationContext for time-based updates. Emits `projectile_spawned`, `projectile_moved`, `projectile_destroyed`.

5. **CollisionSystem**: Detects projectile collisions with units. Produces DamageAction when collision occurs. Emits `projectile_collided`. Never modifies HP directly.

6. **RangedAttackModel**: Extends AttackModel. Resolves ProjectileDefinition from unit's projectile_id, spawns projectile via ProjectileFactory, returns DamageAction with 0 damage (actual damage applied later by CollisionSystem).

7. **ProjectileDefinitionRegistry**: Registers and resolves projectile definitions by string identifier.

### Architecture Flow

```
Ranged Unit Attack Timer Expires
  ↓
CombatSystem creates AttackCommand
  ↓
CommandDispatcher.dispatch(command)
  ↓
AttackSystem.execute(attacker, target)
  ↓
RangedAttackModel.execute()
  ↓
1. Resolve ProjectileDefinition from attacker.definition.projectile_id
2. ProjectileFactory.create_projectile() -> ProjectileInstance
3. EventBus.projectile_spawned emitted
4. Return DamageAction(0, attacker, target)
  ↓
CombatSystem._apply_damage_action(action)
  ↓
action.damage is 0, no immediate damage
  ↓
ProjectileSystem._physics_process()
  ↓
Update projectile movement using SimulationContext.delta_time
  ↓
CollisionSystem._physics_process()
  ↓
Detect projectile collision with target
  ↓
1. EventBus.projectile_collided emitted
2. Create DamageAction with projectile damage
3. EventBus.action_performed emitted
  ↓
CombatSystem consumes DamageAction
  ↓
target.take_damage(action.damage)
  ↓
EventBus.action_performed emitted
```

### Key Design Decisions

1. **RangedAttackModel returns 0-damage DamageAction**: This maintains the AttackModel contract while deferring actual damage to CollisionSystem. CombatSystem checks if damage > 0 before applying.

2. **CollisionSystem produces DamageAction**: CollisionSystem creates DamageAction when collision occurs, maintaining the principle that only CombatSystem modifies HP.

3. **ProjectileSystem uses SimulationContext**: All time-based updates use SimulationContext.delta_time, never engine delta directly.

4. **Event-driven lifecycle**: Projectile lifecycle is fully event-driven (spawned, moved, collided, destroyed), enabling future features like replay and analytics.

5. **Debug rendering optional**: ProjectileInstance supports optional debug rendering (ID, speed, remaining distance, target) via debug_mode flag.

### Data Configuration

**projectiles.json**:
```json
{
  "projectiles": [
    {
      "id": "arrow_basic",
      "display_name": "Basic Arrow",
      "speed": 300.0,
      "max_range": 400.0,
      "damage": 15,
      "projectile_type": "arrow",
      "image": ""
    }
  ]
}
```

**cards.json** (ranged units):
```json
{
  "id": "egyptian_archer_001",
  "stats": {
    "attack_model": "ranged",
    "projectile_id": "arrow_basic"
  }
}
```

## Alternatives Considered

### Alternative 1: Immediate Damage with Visual Projectile

RangedAttackModel could apply damage immediately and spawn a visual-only projectile for feedback.

**Pros**:
- Simpler implementation
- No collision detection needed
- Maintains synchronous attack pipeline

**Cons**:
- No travel time (instant hit)
- Not realistic for ranged combat
- Cannot support dodging or interception
- Violates the principle that projectiles are first-class entities

**Why Rejected**: Ranged attacks should have travel time to be strategically meaningful. Instant hits don't represent ranged combat accurately.

### Alternative 2: Projectile Modifies HP Directly

ProjectileInstance could call target.take_damage() directly on collision.

**Pros**:
- Simpler architecture
- Fewer systems involved

**Cons**:
- Violates SRP (ProjectileInstance would have combat responsibility)
- CombatSystem no longer the sole HP modifier
- Harder to track damage sources
- Breaks the Action Framework pattern

**Why Rejected**: Violates the core architectural principle that CombatSystem is the only system that modifies HP. The Action Framework exists specifically to decouple damage calculation from damage application.

### Alternative 3: RangedAttackModel Applies Damage After Delay

RangedAttackModel could use a timer to apply damage after a delay, simulating travel time.

**Pros**:
- Maintains synchronous attack pipeline
- No projectile entity needed

**Cons**:
- No visual feedback
- Cannot support projectile interception
- Harder to implement complex projectile behaviors (homing, AOE, etc.)
- Not extensible for future projectile types

**Why Rejected**: Lacks visual feedback and extensibility. Projectiles should be first-class entities to support future features like piercing, AOE, homing, etc.

### Alternative 4: Separate RangedAttackModel with Different Contract

Create a separate RangedAttackModel with a different contract (e.g., returns ProjectileInstance instead of DamageAction).

**Pros**:
- Clear separation between melee and ranged
- No 0-damage hack

**Cons**:
- Violates Liskov Substitution Principle
- AttackSystem would need to handle different return types
- Breaks polymorphism
- More complex code

**Why Rejected**: Violates LSP and breaks polymorphism. The 0-damage DamageAction approach maintains the contract while deferring damage application.

### Alternative 5: Projectile as Component of UnitInstance

Instead of separate entity, projectile could be a component of UnitInstance.

**Pros**:
- Simpler entity management
- Easier to track projectile ownership

**Cons**:
- Violates SRP (UnitInstance would have projectile responsibility)
- Harder to support multiple projectiles per unit
- Not extensible for complex projectile behaviors
- Breaks the entity-component pattern

**Why Rejected**: Violates SRP and limits extensibility. Projectiles should be independent entities to support complex behaviors and multiple projectiles.

## Consequences

### Positive

1. **Extensible projectile system**: Easy to add new projectile types (rock, spear, fireball, lightning, magic missile) by adding new ProjectileDefinition entries.

2. **Travel time**: Ranged attacks now have realistic travel time, making them strategically different from melee attacks.

3. **Visual feedback**: Projectiles provide visual feedback for ranged attacks, improving game feel.

4. **Collision detection**: Projectiles can be intercepted or miss their target, adding strategic depth.

5. **Event-driven lifecycle**: Full event-driven lifecycle enables future features like replay, analytics, and achievements.

6. **Debug support**: Optional debug rendering helps with development and balancing.

7. **Maintains architectural principles**: CombatSystem remains the sole HP modifier, Actions flow through EventBus, systems use SimulationContext.

8. **Data-driven**: All projectile properties loaded from JSON, no hardcoded values.

9. **Reusable components**: ProjectileFactory, ProjectileSystem, and CollisionSystem can be reused for other projectile-based mechanics (abilities, traps, etc.).

10. **Future-proof**: Architecture supports future features like AOE, piercing, homing, ricochet, chain attacks.

### Negative

1. **Additional complexity**: Two new systems (ProjectileSystem, CollisionSystem) add complexity to the architecture.

2. **Performance overhead**: Projectile movement and collision detection add per-frame overhead. However, this is minimal for typical battlefield sizes.

3. **Timing complexity**: Ranged attacks now have asynchronous damage application, which can be harder to reason about than synchronous melee attacks.

4. **Collision detection accuracy**: Simple distance-based collision detection may not be accurate for all projectile types. May need refinement for complex shapes.

5. **Debug mode overhead**: Debug rendering adds overhead when enabled. Should only be used in development builds.

### Neutral

1. **0-damage DamageAction**: RangedAttackModel returns a 0-damage DamageAction, which is a bit of a hack. However, it maintains the AttackModel contract and is clearly documented.

2. **Event ordering**: Projectile collision and damage application happen in separate frames, which may affect event ordering. Listeners should be aware of this.

3. **Projectile cleanup**: Projectiles are cleaned up when they expire or collide. If a projectile's target dies before collision, the projectile continues until it expires.

## Migration Strategy

### Phase 1: Foundation (Current)

- Add ProjectileDefinition, ProjectileInstance, ProjectileFactory
- Add ProjectileSystem, CollisionSystem
- Add RangedAttackModel
- Add ProjectileDefinitionRegistry
- Extend SpatialQuerySystem with projectile queries
- Add EventBus signals for projectiles
- Create projectile JSON definitions
- Update UnitDefinition to include projectile_id
- Update cards.json with ranged units
- Update TargetingSystem for ranged units
- Update CombatSystem for ranged units
- Add debug rendering

### Phase 2: Additional Projectile Types (Future)

- Add more ProjectileDefinition entries (rock, spear, fireball, lightning, magic missile)
- Implement projectile-specific behaviors (AOE, piercing, homing, etc.)
- Add projectile-specific visuals and effects

### Phase 3: Advanced Features (Future)

- Implement projectile interception (units can dodge or block projectiles)
- Add projectile physics (gravity, wind, etc.)
- Implement projectile chaining (projectiles that spawn other projectiles)
- Add projectile status effects (projectiles that apply buffs/debuffs)

### Phase 4: Optimization (Future)

- Implement object pooling for projectiles
- Add spatial partitioning for collision detection
- Optimize projectile movement for large numbers of projectiles

## Relationship to Action Framework

The Projectile Layer complements the Action Framework:

| Aspect | Action Framework | Projectile Layer |
|--------|------------------|------------------|
| **Purpose** | Represent outcomes | Represent entities |
| **Timing** | Immediate | Delayed (travel time) |
| **Flow** | System -> EventBus -> Listeners | Entity -> System -> EventBus |
| **Examples** | DamageAction, HealAction | ProjectileInstance, ProjectileSystem |

**Flow**:
```
RangedAttackModel -> ProjectileFactory -> ProjectileInstance -> ProjectileSystem -> CollisionSystem -> DamageAction -> CombatSystem
```

## Future Projectile Types

The framework supports future projectile types without modification:

- **Rock**: Heavy, slow, high damage
- **Spear**: Fast, medium damage, piercing
- **Fireball**: AOE, explosion radius
- **Lightning**: Chain attacks, multiple targets
- **Magic Missile**: Homing, guaranteed hit

Each projectile type:
1. Defined in projectiles.json
2. Automatically loaded by ProjectileDefinitionRegistry
3. Has its own speed, range, damage
4. Can have unique behaviors (AOE, piercing, homing, etc.)

## Verification

Gameplay behavior changes:

- Ranged units now spawn projectiles instead of applying immediate damage
- Projectiles travel over time and collide with targets
- Damage is applied when projectile collides with target
- Ranged units can attack from a distance

Existing gameplay preserved:

- Melee combat unchanged
- Unit spawning unchanged
- Formation unchanged
- Targeting unchanged
- Death unchanged
- Movement unchanged
- Economy unchanged

Architectural principles maintained:

- CombatSystem remains the only system that modifies HP
- Actions flow through EventBus
- Systems use SimulationContext for time-based updates
- Data-driven configuration
- Event-driven lifecycle
