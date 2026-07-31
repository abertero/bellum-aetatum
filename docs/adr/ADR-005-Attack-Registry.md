# ADR-005: Attack Model Registry

## Status

Accepted.

## Problem

`AttackSystem` previously held a dictionary of attack model instances and directly instantiated concrete attack classes (e.g., `MeleeAttackModel`) in its constructor. This violated the dependency inversion principle: `AttackSystem` had compile-time knowledge of specific attack implementations.

Adding a new attack type required modifying `AttackSystem._init()` to register the new model, coupling the system to every concrete implementation. As the number of attack types grows, `AttackSystem` would accumulate dependencies on all of them.

## Decision

Introduce `AttackModelRegistry`, a dedicated class responsible for:

1. Registering attack models by string identifier.
2. Resolving attack models by identifier at runtime.

`AttackSystem` now receives an `AttackModelRegistry` through its constructor and uses it to look up the appropriate `AttackModel` implementation. `AttackSystem` never references concrete attack classes.

### Registration

Registration happens externally in `BattleScene._setup_attack_system()`:

```gdscript
var registry := AttackModelRegistry.new()
registry.register("melee", MeleeAttackModel.new())
_attack_system = AttackSystem.new(registry)
```

### Resolution

`AttackSystem._resolve_damage()` reads `attacker.definition.attack_model` and calls `_registry.resolve(model_key)` to obtain the implementation. If no model is registered for the key, a default empty `DamageResult` is returned.

### Interface

`AttackModel` serves as the abstract base class. All attack models extend it and implement `execute(attacker: UnitInstance, target: UnitInstance) -> DamageResult`.

## Alternatives Considered

### 1. Switch Statement in AttackSystem

`AttackSystem` could use a `match` expression on `attack_model` to select the implementation directly.

**Rejected:** This couples `AttackSystem` to every concrete attack class. Adding a new attack type requires modifying `AttackSystem`, violating the Open/Closed Principle.

### 2. Static Registry (Singleton)

`AttackModelRegistry` could be an autoload singleton.

**Rejected:** A singleton creates global mutable state and makes testing harder. Constructor injection keeps the dependency explicit and testable. The registry is created once in `BattleScene` and passed to `AttackSystem`, which is sufficient for the current scope.

### 3. Keep Dictionary Inside AttackSystem

The current dictionary-based approach could remain inside `AttackSystem`.

**Rejected:** This still requires `AttackSystem` to instantiate concrete models in `_init()`. Extracting the registry separates the concern of model registration from attack execution, giving each class a single responsibility.

### 4. Resource-Based Registration

Attack models could be defined as Godot Resources and loaded from files.

**Rejected:** Over-engineering for the current scope. Attack models are stateless logic, not data. A simple in-memory registry is sufficient. Resources could be introduced later if mod support is needed.

## Consequences

### Positive

- **Open/Closed Principle**: New attack types are added by creating a new `AttackModel` subclass and registering it. `AttackSystem` is never modified.
- **Single Responsibility**: `AttackModelRegistry` handles registration. `AttackSystem` handles execution. `AttackModel` handles damage calculation.
- **Testability**: `AttackSystem` can be tested with a mock registry.
- **Explicit Dependencies**: `AttackSystem` constructor makes its dependency on the registry visible.

### Negative

- **Slightly more wiring**: `BattleScene` must create and configure the registry before passing it to `AttackSystem`. This is a one-time setup cost.
- **Additional class**: One more file to maintain. The registry is small (15 lines) and unlikely to change often.

### Neutral

- **Runtime lookup**: Model resolution is a dictionary lookup instead of direct reference. The performance impact is negligible for the expected number of attack types.
