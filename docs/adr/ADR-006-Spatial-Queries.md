# ADR-006: Spatial Query System

## Status

Accepted.

## Problem

Battlefield queries were scattered across multiple systems. `TargetingSystem` directly accessed `BattleGroup` internals (`player_formation`, `enemy_formation`, `get_next_target()`). `CombatSystem` directly iterated `FormationSystem.get_battle_groups()` and called `group.get_all_units()`. `BattleGroup` embedded gameplay rules via `get_next_target()`.

This created several issues:

1. **Tight coupling**: Systems depended on `BattleGroup` implementation details.
2. **Scattered queries**: The same type of query (e.g., "find units by owner") could be implemented differently in different systems.
3. **Gameplay rules in data structures**: `BattleGroup.get_next_target()` encoded targeting logic inside a data container.
4. **No single point of change**: Adding a new query type required modifying multiple systems.

## Decision

Introduce `SpatialQuerySystem`, a dedicated query facade responsible for all battlefield spatial queries.

### Responsibilities

- Return battlefield information.
- Never modify gameplay state.
- Never move units, calculate combat, calculate targets, or modify HP.

### Supported Queries

| Method | Returns |
|---|---|
| `get_frontline(for_unit)` | The frontline unit opposing the given unit within its battle group. |
| `get_units_in_formation(owner)` | All alive units in formations for the given owner. |
| `get_units_by_owner(owner)` | All alive units belonging to the given owner (including moving units). |
| `get_units_by_state(state)` | All alive units in the given state. |
| `get_closest_enemy(unit)` | The closest living enemy to the given unit. |

### Internal Implementation

`SpatialQuerySystem` is a `RefCounted` that holds a reference to `FormationSystem`. It internally uses `BattleGroup` to resolve queries but does not expose `BattleGroup` in its public API (except for debug helpers).

### Dependency Changes

```
Before:
  TargetingSystem -> FormationSystem -> BattleGroup
  CombatSystem    -> FormationSystem -> BattleGroup

After:
  TargetingSystem -> SpatialQuerySystem -> FormationSystem -> BattleGroup
  CombatSystem    -> EventBus (unit tracking, no FormationSystem dependency)
```

### BattleGroup Changes

`BattleGroup.get_next_target()` was removed. This method encoded a gameplay rule (targeting logic) inside a data structure. The equivalent logic now lives in `SpatialQuerySystem.get_frontline()`.

`BattleGroup` now exposes only low-level formation information: formations, frontline lookup, unit membership, and cleanup.

### CombatSystem Changes

`CombatSystem` no longer depends on `FormationSystem`. Instead, it tracks units through `EventBus` signals (`unit_spawned`, `unit_died`). It processes only units that are in battle groups (checked via `unit.battle_group != null`), preserving identical behavior.

## Alternatives Considered

### 1. Keep Queries in BattleGroup

`BattleGroup` could continue to provide query methods like `get_next_target()`.

**Rejected:** This embeds gameplay rules in a data structure. `BattleGroup` should be a passive container, not a source of targeting logic. It also means every system that needs queries must know about `BattleGroup` directly.

### 2. Use EventBus for Queries

Queries could be implemented as request/response signals on `EventBus`.

**Rejected:** Synchronous queries are a poor fit for an asynchronous signal bus. Systems need immediate answers (e.g., "who is the frontline?"), not deferred responses. A direct method call is simpler and more appropriate.

### 3. Make SpatialQuerySystem an Autoload Singleton

`SpatialQuerySystem` could be an autoload like `EventBus`.

**Rejected:** Constructor injection keeps dependencies explicit and testable. `SpatialQuerySystem` depends on `FormationSystem`, which is created per-battle. An autoload would need to be re-initialized each battle, adding complexity without benefit.

### 4. Expose BattleGroup in SpatialQuerySystem API

`SpatialQuerySystem` could return `BattleGroup` references to callers.

**Rejected:** This leaks the internal organization. Callers would still depend on `BattleGroup` internals. The API should return only the data callers need (units, positions), not the structures that organize them.

## Consequences

### Positive

- **Single point of change**: New query types are added to `SpatialQuerySystem` only.
- **Decoupled systems**: `TargetingSystem` no longer knows about `BattleGroup`. `CombatSystem` no longer knows about `FormationSystem`.
- **Clean data structures**: `BattleGroup` is a passive container with no gameplay rules.
- **Stable API**: Future milestones can add queries without modifying existing methods or callers.
- **Testability**: `SpatialQuerySystem` can be tested with a mock `FormationSystem`.

### Negative

- **One more layer**: Queries now go through an additional indirection. The performance impact is negligible (one extra function call per query).
- **Slightly more wiring**: `BattleScene` must create and configure `SpatialQuerySystem`. This is a one-time setup cost.

### Neutral

- **RefCounted, not Node**: `SpatialQuerySystem` does not need `_physics_process`. It is called by other systems, matching the pattern of `AttackSystem` and `SpawnSystem`.
- **Debug helpers expose BattleGroup**: Methods like `get_battle_group_count()` and `get_units_in_group()` are provided for the debug panel. These are not used by gameplay systems.
