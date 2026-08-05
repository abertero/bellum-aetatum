# ADR-014: Match Flow Engine

## Status

Accepted.

## Context

The game requires an explicit match lifecycle manager. Without it:
- Gameplay systems implicitly determine match state (e.g., battle_started emitted immediately in _ready)
- No countdown, pause, or victory/defeat flow
- No data-driven victory conditions
- No way to gate gameplay on match state
- Future game modes cannot reuse match lifecycle

The architecture already provides:
- SimulationContext for time management (supports pause)
- EventBus for decoupled communication
- Definition/Registry/Loader pattern for data
- Ability Composition Engine for reusable ability behaviors

## Decision

Introduce a Match Flow Engine with explicit state management, pluggable victory conditions, and an Ability Pipeline abstraction.

### MatchState

Enum defining match lifecycle states:
- LOADING: Initial state while systems initialize
- INITIALIZING: Brief transition state
- COUNTDOWN: Pre-match countdown timer
- RUNNING: Active gameplay
- PAUSED: Gameplay suspended (SimulationContext.paused = true)
- VICTORY: Player won
- DEFEAT: Player lost
- DRAW: Match ended without winner
- FINISHED: Match fully concluded

### MatchFlowSystem

Node-based system that owns match lifecycle. Responsibilities:
- Manage state transitions (explicit, never implicit)
- Track elapsed match time (separate from SimulationContext)
- Evaluate victory conditions each frame during RUNNING
- Pause/resume via SimulationContext.paused
- Emit match events through EventBus
- Never modifies gameplay directly

### MatchCondition

Pluggable interface for victory conditions. Each condition implements `check(context) -> bool`. Conditions are loaded from `data/match_rules.json`.

### Initial Conditions

- **DestroyEnemyNexusCondition**: Enemy nexus HP <= 0
- **DestroyPlayerNexusCondition**: Player nexus HP <= 0
- **TimeLimitCondition**: Elapsed match time >= configured limit

### NexusSystem

Manages base HP for each team. Provides `damage_nexus(team, amount)` API. Emits `nexus_damaged` and `nexus_destroyed` events. MatchFlowSystem reads nexus state for victory evaluation.

### Ability Pipeline

Refactored ability execution from flat component list to pipeline of nodes:
- **AbilityPipeline**: Ordered list of AbilityPipelineNode objects
- **AbilityPipelineNode**: Wraps a component execution (or future node types)
- **AbilityPipelineExecutor**: Executes nodes sequentially, collects commands

### Backward Compatibility

AbilityDefinition auto-migrates: if JSON has `components` but no `pipeline`, a sequential pipeline is created from components. Existing abilities.json works without changes.

### Match Rules JSON

```json
{
  "countdown_duration": 3.0,
  "time_limit": 300.0,
  "nexus_hp": 100,
  "victory_conditions": [
    {"type": "DestroyEnemyNexus"},
    {"type": "DestroyPlayerNexus"},
    {"type": "TimeLimit"}
  ]
}
```

### Gameplay Gating

BattleScene gates gameplay actions on match state:
- Card playing only during RUNNING
- Enemy spawning only during RUNNING
- Ability triggers only during RUNNING
- Ability buttons only during RUNNING

## Alternatives Considered

### 1. Match state in BattleScene
BattleScene could track match state directly. Rejected because it violates SRP. MatchFlowSystem should own lifecycle, similar to how AbilitySystem owns ability execution.

### 2. Hardcoded victory conditions
Victory logic could be hardcoded in MatchFlowSystem. Rejected because it violates OCP. Pluggable conditions allow new win types without modifying MatchFlowSystem.

### 3. Match state in SimulationContext
SimulationContext could track match state alongside time. Rejected because it conflates time management with match lifecycle. Separate concerns.

### 4. Ability pipeline as inheritance hierarchy
Different pipeline node types could use inheritance. Rejected because composition is more flexible. A single AbilityPipelineNode with a type field allows data-driven pipeline construction.

### 5. Nexus HP in UnitInstance
Base HP could be tracked by a special "nexus unit". Rejected because bases are not units. NexusState is a simpler, dedicated concept.

## Consequences

### Positive
- Match lifecycle is explicit and data-driven
- Victory conditions are pluggable via JSON
- Countdown, pause, victory/defeat flows are managed
- Gameplay systems remain independent from match state
- Ability pipeline enables future node types (delay, condition, branch)
- Existing abilities migrate automatically
- Future game modes reuse MatchFlowSystem with different rules

### Negative
- MatchFlowSystem adds another system to initialize
- NexusSystem adds base HP tracking overhead
- battle_scene.gd grows to accommodate match UI and gating

### Risks
- MatchFlowSystem must be initialized after SimulationContext
- NexusSystem must be initialized before MatchFlowSystem
- Conditions must handle null/invalid context gracefully

## Migration Strategy

AbilityDefinition backward-compatible: existing `components` arrays auto-convert to sequential pipelines. No changes needed to abilities.json.

BattleScene initialization order updated: match rules and nexus system created before battlefield, match flow system created after combat systems.

## Files Created

| File | Purpose |
|---|---|
| `core/MatchState.gd` | Match state enum and utilities |
| `definitions/MatchRulesDefinition.gd` | Data container for match rules |
| `entities/NexusState.gd` | Runtime nexus HP tracking |
| `conditions/MatchCondition.gd` | Base condition interface |
| `conditions/DestroyEnemyNexusCondition.gd` | Enemy nexus destroyed check |
| `conditions/DestroyPlayerNexusCondition.gd` | Player nexus destroyed check |
| `conditions/TimeLimitCondition.gd` | Time limit check |
| `pipelines/AbilityPipeline.gd` | Ordered node list |
| `pipelines/AbilityPipelineNode.gd` | Pipeline node wrapper |
| `pipelines/AbilityPipelineExecutor.gd` | Sequential node executor |
| `systems/MatchFlowSystem.gd` | Match lifecycle management |
| `systems/NexusSystem.gd` | Nexus HP management |
| `data/match_rules.json` | Match rules configuration |

## Files Modified

| File | Changes |
|---|---|
| `core/EventBus.gd` | Added 8 match/nexus signals |
| `definitions/AbilityDefinition.gd` | Added pipeline field with backward compatibility |
| `systems/AbilitySystem.gd` | Uses AbilityPipelineExecutor instead of flat component loop |
| `scenes/battle_scene.gd` | Integrated MatchFlowSystem, NexusSystem, match UI, gating |
