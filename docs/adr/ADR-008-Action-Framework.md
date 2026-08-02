# ADR-008: Action Framework

## Status

Accepted.

## Context

The attack pipeline produced `DamageResult`, a lightweight data carrier with fields for damage, source, target, critical, and blocked. While functional, this approach had several limitations:

1. **No unified action representation.** Each gameplay operation (damage, healing, spawning, status effects) would need its own result type, leading to scattered data structures with no common interface.

2. **Primitive signal parameters.** `EventBus.unit_damaged(unit, damage)` emitted raw values. Listeners received disconnected primitives instead of a cohesive object describing what happened.

3. **No extensibility for future operations.** Healing, spawning, projectiles, status effects, abilities, and economy operations all need to communicate outcomes. Without a common abstraction, each would introduce its own signal signatures and data types.

4. **Duplicated result structures.** `DamageResult` carried the same fields that a proper action object would need (damage, source, target, critical, blocked). Maintaining both a result type and an action type would duplicate data.

## Decision

Introduce an Action Framework as a new `actions/` layer. Every gameplay operation produces a `GameAction` object representing its outcome.

### GameAction (Base Class)

`GameAction` is a `RefCounted` base class providing the common contract:

| Field | Type | Purpose |
|---|---|---|
| `action_id` | `String` | Unique sequential identifier |
| `timestamp` | `float` | Creation time in seconds |
| `source` | `Node` | Who initiated the action |
| `target` | `Node` | Who is affected |
| `metadata` | `Dictionary` | Extensible data for future use |

Actions are created via constructor or static factory methods and should not be modified after creation (immutability by convention).

### DamageAction

`DamageAction` extends `GameAction` with damage-specific fields:

| Field | Type | Purpose |
|---|---|---|
| `damage` | `int` | Damage amount |
| `critical` | `bool` | Whether the damage is critical |
| `blocked` | `bool` | Whether the damage was blocked |

Created via `DamageAction.create(damage, source, target, critical, blocked, metadata)`.

### Pipeline Changes

```
Before:
  AttackSystem.execute() -> DamageResult
  CombatSystem._apply_damage_result(DamageResult)
  EventBus.attack_finished(attacker, target, DamageResult)
  EventBus.unit_damaged(unit, damage)

After:
  AttackSystem.execute() -> DamageAction
  CombatSystem._apply_damage_action(DamageAction)
  EventBus.attack_finished(DamageAction)
  EventBus.action_performed(DamageAction)
```

### EventBus Changes

- `attack_finished` now carries a `GameAction` instead of separate attacker/target/result parameters.
- `action_performed` is a new generic signal for broadcasting any `GameAction`.
- `unit_damaged` is removed. The `action_performed` signal replaces it with a rich object.

### DamageResult Removal

`DamageResult` is removed. `DamageAction` replaces it entirely, carrying the same fields plus the `GameAction` contract. No duplicated result structures.

## Alternatives Considered

### 1. Keep DamageResult, Add Action Layer Separately

Maintain `DamageResult` for the attack pipeline and introduce `GameAction` as a separate abstraction for future operations.

**Rejected:** This creates duplicated structures. `DamageResult` and a hypothetical `DamageAction` would carry identical data. One source of truth is cleaner.

### 2. Use Signals as Actions

Instead of action objects, emit detailed signals for each operation type (e.g., `damage_dealt(damage, source, target, critical, blocked)`).

**Rejected:** This leads to signal proliferation. Each new operation type needs a new signal with its own parameter list. A `GameAction` object is more extensible and can be passed through a single `action_performed` signal.

### 3. Make GameAction a Resource

Use `extends Resource` instead of `extends RefCounted` for `GameAction`, enabling serialization and inspector editing.

**Rejected:** Actions are transient runtime objects. They represent things that happened, not persistent data. `RefCounted` is lighter weight and more appropriate for short-lived objects. Serialization can be added later if replay or logging requires it.

### 4. Mutable Actions with Builder Pattern

Allow actions to be modified after creation through a builder pattern, enabling progressive construction during the attack pipeline.

**Rejected:** Immutability after creation is simpler and safer. The factory method `DamageAction.create()` constructs the action in one step with all required data. Progressive construction adds complexity without benefit in the current pipeline.

### 5. Interface-Based Design

Use a GDScript "interface" pattern (abstract base class with virtual methods) for `GameAction`.

**Rejected:** GDScript does not have true interfaces. A base class with data fields is sufficient. Future action types extend `GameAction` and add their own fields. Virtual methods can be added when behavior is needed.

## Consequences

### Positive

- **Unified abstraction.** All gameplay operations produce `GameAction` objects. Listeners handle one type, not many.
- **Extensibility.** New action types (HealAction, SpawnAction, etc.) extend `GameAction` without modifying existing code.
- **Rich signal data.** `action_performed(action)` provides complete context. Listeners can inspect `action.metadata`, `action.source`, `action.target`, and type-specific fields.
- **No duplication.** `DamageResult` is removed. `DamageAction` is the single damage outcome type.
- **Immutability convention.** Actions are created via factory methods and not modified afterward, reducing bugs from unexpected mutation.
- **Future-proof.** Logging, replay, undo, and analytics can consume `GameAction` objects uniformly.

### Negative

- **One more layer.** The `actions/` directory adds a new layer to the architecture. The indirection cost is negligible (one object allocation per action).
- **RefCounted immutability is by convention.** GDScript cannot enforce true immutability. Developers must follow the convention of not modifying actions after creation.
- **Migration cost.** All references to `DamageResult` must be updated. This is a one-time cost.

### Neutral

- **Sequential IDs.** `action_id` uses a static counter. This is simple and sufficient for a single-session game. If multi-session or networked play is needed, a different ID strategy would be required.
- **No virtual methods yet.** `GameAction` is currently a data container. Virtual methods (e.g., `apply()`, `revert()`) can be added when behavior is needed.
