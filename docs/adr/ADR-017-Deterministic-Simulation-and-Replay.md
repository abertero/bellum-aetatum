# ADR-017: Deterministic Simulation and Replay

## Status

Accepted.

## Context

The engine lacks deterministic simulation guarantees. Randomness is uncontrolled (using Godot global `randi()` and `randf_range()`), IDs are generated from static counters, and the simulation runs at variable timestep tied to rendering FPS. This makes it impossible to:

1. Reproduce a match from initial state and command sequence
2. Record and replay matches deterministically
3. Detect simulation divergence (desync)
4. Validate content version compatibility for replays
5. Support future multiplayer lockstep or rollback netcode

The architecture already separates Commands (inputs) from Events (consequences), and Systems are free from hidden engine state. The foundation for determinism exists but needs completion.

## Decision

Introduce deterministic simulation infrastructure as a layer on top of the existing architecture. The simulation becomes reproducible from:

- Initial Match State (MatchSnapshot)
- GameMode
- Content Version
- Random Seed
- Ordered Commands (CommandLog)

### Deterministic Random Service

`DeterministicRandom` uses a Linear Congruential Generator (LCG) seeded from `SimulationContext`. All gameplay randomness flows through this service. No uncontrolled `randi()` or `randf_range()` calls in gameplay code.

### Fixed Timestep

`SimulationContext` accumulates real time and consumes fixed-size simulation ticks (default 30 Hz). Systems advance only during `consume_tick()`. Rendering continues at native FPS independently.

### Deterministic IDs

Entity IDs are generated from `SimulationContext.next_entity_id()` which combines tick number with a per-tick counter. This ensures the same sequence of operations produces the same IDs.

### Command Serialization

All `GameCommand` subclasses implement `serialize()` / `deserialize()`. Commands store IDs and immutable data, not runtime object references. `CommandLog` preserves command order with sequence numbers.

### Match Snapshots

`MatchSnapshot` captures enough state to restore simulation: tick, elapsed time, random seed, match state, world state, economy state, active effects, projectiles, units, cooldowns, command sequence, content version, game mode ID.

### Replay Infrastructure

- `ReplayDefinition`: Serializable replay data container
- `ReplayRecorder`: Listens to CommandDispatcher, records gameplay commands
- `ReplayPlayer`: Restores initial state, replays commands in order
- `ReplayValidator`: Compares expected vs actual state, identifies first divergence
- `StateHasher`: Deterministic FNV-1a-style hash of gameplay state

### Schema Versioning

All JSON data files include `schema_version`. `SchemaValidator` checks compatibility during content pipeline runs. `ContentMigrationRegistry` supports future migrations. `ContentVersion` identifies the exact content used for a replay.

### Desync Diagnostics

When replay diverges, the validator reports: tick, first divergent entity, expected value, actual value, system responsible, command responsible.

## Determinism Requirements

1. All gameplay randomness originates from `SimulationContext.get_random()`
2. Entity IDs are deterministic (tick + sequence counter)
3. Simulation advances in fixed timestep increments
4. Commands are the authoritative input; events are consequences
5. No gameplay system reads engine clock, node paths, or memory addresses
6. Serialization excludes Node references, Textures, Animations, UI state

## Command Authority

Commands are the only input to the simulation. Both player and AI commands flow through `CommandDispatcher`. The `CommandLog` records every dispatched command with tick and sequence number. Replay replays the exact same command sequence.

## Fixed Timestep

```
Render Frames
  -> Simulation Accumulator
  -> Fixed Simulation Tick (consume_tick)
  -> Systems
```

Default: 30 ticks/second. Configurable via `SimulationContext.fixed_delta_time`.

## Snapshots

Snapshots capture full simulation state at a point in time. Used for:
- Initial state for replay recording
- Checkpoints during long replays
- State comparison during validation

## State Hashing

FNV-1a-style hash over deterministic state only:
- Tick, match state
- Nexus HP
- Unit positions, HP, states
- Economy values

Excludes: object addresses, node references, textures, rendering state.

## Alternatives Considered

### Full ECS with explicit state arrays

Rejected: Too invasive. Current architecture already separates state (WorldState, UnitInstance) from behavior (Systems). Adding determinism as a layer is less disruptive.

### Frame-based simulation (no fixed timestep)

Rejected: Non-deterministic across different frame rates. Fixed timestep ensures identical behavior regardless of rendering performance.

### Separate replay engine

Rejected: Duplicates gameplay logic. ReplayPlayer uses existing Systems, ensuring the same code paths execute.

### Global mutable random state

Rejected: Violates determinism. `DeterministicRandom` is owned by `SimulationContext` and accessed explicitly.

## Consequences

### Positive

- Matches are fully reproducible
- Replay recording/playback uses existing simulation code
- Desync detection for debugging and future multiplayer
- Content version compatibility prevents invalid replays
- Schema versioning enables safe content evolution

### Negative

- Fixed timestep may feel different from variable timestep at very low FPS
- Serialization adds complexity to Commands
- State hashing adds per-tick overhead (configurable interval)
- Schema validation may reject older content files

### Neutral

- AI decision timer still uses real delta within decision cycle (acceptable since decisions are coarse-grained)
- Rendering continues independently of simulation

## Migration Strategy

1. All existing JSON files updated with `schema_version: "1.0.0"`
2. No historical migrations needed (first versioned schema)
3. `ContentMigrationRegistry` ready for future version bumps
4. Replays refuse to play with incompatible content versions
