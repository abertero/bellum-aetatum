# ADR-010: Economy Layer

## Status

Accepted

## Context

The game previously had no resource management system. Players could spawn unlimited units without any cost, and the AI had the same unlimited spawning capability. This created several issues:

1. **No strategic depth**: Players could spam units without consequence
2. **No resource management**: No decision-making about when to spend resources
3. **AI cheating**: AI had unlimited resources, making it unfair
4. **No progression**: No sense of building up resources over time
5. **No balance**: Cards had cost values but no mechanism to enforce them

The Command Framework (ADR-009) established that commands represent intent and should be validated before execution. However, there was no validation layer to check if players could afford their actions.

## Decision

Introduce an Economy Layer that manages resources, validates spending, and enforces costs for all gameplay actions.

### Core Components

1. **SimulationContext**: Manages simulation time (delta_time, elapsed_time, time_scale, paused). Provides a consistent time source for all systems.
2. **ResourceDefinition**: Pure data class defining resource properties (id, display_name, maximum, starting_value, regeneration_rate).
3. **ResourceInstance**: Runtime state for a resource (current_value, generator_level, accumulated_regeneration).
4. **EconomySystem**: Manages resources for all players/teams. Handles regeneration, spending, and validation.

### Architecture

```
Input Source (Player/AI/Replay)
    ↓
GameCommand (immutable request)
    ↓
CommandDispatcher (routing + validation)
    ↓
EconomySystem (validates and spends resources)
    ↓
System (execution)
    ↓
GameAction (result)
    ↓
EventBus (broadcast)
```

### Validation Flow

1. CommandDispatcher receives a PlayCardCommand
2. Calls `_validate_play_card()` to check if player can afford the cost
3. If validation passes, calls `_spend_resource()` to deduct the cost
4. Then dispatches to SpawnSystem to create the unit
5. If validation fails, returns null and the command is not executed

### Resource Management

- Each team (player, enemy) has its own resource instances
- Resources regenerate automatically based on `regeneration_rate * generator_level`
- Resources have a maximum cap
- Spending is atomic: either the full cost is deducted or nothing happens
- All resource changes emit EventBus signals for observation

### SimulationContext

- Provides `delta_time`, `elapsed_time`, `time_scale`, `paused`
- Updated by BattleScene in `_physics_process()`
- Used by EconomySystem for regeneration calculations
- Never queries engine clock directly
- Future: will support fixed timestep, replay, time scaling, pause, slow motion, deterministic multiplayer

### Implementation Details

**SimulationContext**:
- `delta_time`: Time since last frame, scaled by time_scale
- `elapsed_time`: Total simulation time
- `time_scale`: Multiplier for time progression (default 1.0)
- `paused`: If true, delta_time becomes 0

**ResourceDefinition**:
- Loaded from `data/resources/resources.json`
- Defines resource properties
- Immutable after creation

**ResourceInstance**:
- Created per team per resource type
- Tracks current value, generator level, accumulated regeneration
- Handles regeneration logic with fractional accumulation
- Emits events on changes

**EconomySystem**:
- Node (needs `_physics_process` for regeneration)
- Initialized with SimulationContext
- Loads resource definitions from JSON
- Creates resource instances for each team
- Provides API: `can_afford()`, `spend()`, `get_current()`, `get_maximum()`, `get_regeneration_rate()`, `set_generator_level()`

**CommandDispatcher**:
- Updated to accept EconomySystem in `initialize()`
- Validates PlayCardCommand before dispatching
- Spends resources if validation passes
- Returns null if validation fails

**EventBus**:
- Added `resource_changed(resource_id, current_value, maximum)`
- Added `resource_spent(resource_id, amount, remaining)`
- Added `resource_generated(resource_id, amount, current_value)`

### Data Configuration

**resources.json**:
```json
{
    "resources": [
        {
            "id": "imperium",
            "display_name": "Imperium",
            "maximum": 20,
            "starting_value": 5,
            "regeneration_rate": 1.0
        }
    ]
}
```

**cards.json**:
- Already contains `cost` field for all cards
- Costs range from 2 to 5

### UI Integration

**Resource Panel**:
- Displays current/max Imperium
- Shows regeneration rate
- Updates every frame

**Card Affordability**:
- Cards are greyed out when player cannot afford them
- Visual feedback via `modulate` property
- Updates every frame

### AI Integration

- AI uses the same EconomySystem as the player
- AI checks `can_afford()` before attempting to spawn
- AI skips spawn if it cannot afford the card
- No cheating: AI must wait for resources to regenerate

## Alternatives Considered

### Alternative 1: Direct System Calls for Validation

Each system could validate resources independently.

**Pros**:
- Simpler architecture
- No dispatcher involvement

**Cons**:
- Duplicated validation logic
- Systems become coupled to EconomySystem
- Harder to track all resource spending
- Violates SRP

**Why Rejected**: CommandDispatcher is the natural place for validation. It already routes commands and can validate before dispatching.

### Alternative 2: EventBus for Validation

Use EventBus signals to request validation and wait for response.

**Pros**:
- Fully decoupled

**Cons**:
- Asynchronous validation is complex
- Need to wait for response
- Harder to track command completion
- Mixes request/response with broadcast patterns

**Why Rejected**: Validation should be synchronous. Commands need immediate answers before execution.

### Alternative 3: Resource as Autoload Singleton

Make EconomySystem an autoload like EventBus.

**Pros**:
- Globally accessible
- Simpler initialization

**Cons**:
- Harder to test
- Less explicit dependencies
- Cannot have multiple economy instances
- Violates dependency injection pattern

**Why Rejected**: Constructor injection keeps dependencies explicit and testable. EconomySystem depends on SimulationContext, which is created per-battle.

### Alternative 4: Hardcoded Resource Values

Define resource values directly in code.

**Pros**:
- Simpler
- No JSON loading

**Cons**:
- Not data-driven
- Cannot balance without code changes
- Violates project philosophy

**Why Rejected**: The project is data-driven. All gameplay values should come from JSON.

### Alternative 5: Separate Resource Systems per Team

Each team could have its own EconomySystem instance.

**Pros**:
- Clear separation

**Cons**:
- More complex initialization
- Harder to manage globally
- Duplicated logic

**Why Rejected**: A single EconomySystem managing all teams is simpler. It can use team identifiers to separate resources.

## Consequences

### Positive

1. **Strategic depth**: Players must decide when to spend resources
2. **Fair AI**: AI uses same rules as player
3. **Data-driven**: Resource configuration from JSON
4. **Observable**: All resource changes emit events
5. **Extensible**: Easy to add new resource types
6. **Testable**: EconomySystem can be tested independently
7. **Replay-ready**: SimulationContext supports future replay
8. **Balanced**: Costs enforced consistently
9. **Progression**: Resources build up over time
10. **Clear separation**: Validation in dispatcher, execution in systems

### Negative

1. **Additional layer**: One more system to understand
2. **Validation overhead**: Each command validated before execution (minimal cost)
3. **Complexity**: Resource regeneration logic adds complexity
4. **UI updates**: Need to update UI every frame
5. **Learning curve**: New developers must understand resource flow

### Neutral

1. **Single resource type**: Only Imperium implemented (can add more later)
2. **No upgrade UI**: generator_level exists but no UI to upgrade
3. **Simple regeneration**: Linear regeneration, no complex formulas
4. **No resource sharing**: Teams cannot transfer resources

## Migration Strategy

### Phase 1: Framework Introduction (Current)

- Add SimulationContext, ResourceDefinition, ResourceInstance, EconomySystem
- Integrate validation into CommandDispatcher
- Add UI for resource display and card affordability
- AI respects resource limits
- Existing gameplay remains functional

### Phase 2: Additional Resources (Future)

- Add more resource types (gold, mana, etc.)
- Different regeneration rates
- Resource-specific UI

### Phase 3: Upgrade System (Future)

- UI for generator_level upgrades
- Upgrade costs
- Visual feedback for upgrades

### Phase 4: Advanced Economy (Future)

- Resource trading between teams
- Resource theft/destruction
- Economy-based victory conditions
- Complex regeneration formulas

## Relationship to Command Framework

The Economy Layer complements the Command Framework:

| Aspect | Command | Economy |
|--------|---------|---------|
| **Purpose** | Route requests | Validate and spend |
| **Timing** | Before execution | Before execution |
| **Responsibility** | Routing | Resource management |
| **Flow** | Input → Dispatcher → System | Dispatcher → Economy → System |

**Flow**:
```
Command (request) → CommandDispatcher → EconomySystem (validate/spend) → System (execute) → Action (result)
```

## Future Resource Types

The framework supports future resource types without modification:

- **Gold**: Currency for purchases
- **Mana**: For abilities
- **Supply**: Unit cap
- **Influence**: For diplomacy
- **Research**: For technology

Each resource type:
1. Defined in resources.json
2. Automatically loaded by EconomySystem
3. Has its own regeneration rate
4. Can be spent independently

## Verification

Gameplay behavior changes:

- Players cannot spawn units without sufficient resources
- Resources regenerate over time
- AI respects same resource limits
- Cards are greyed out when unaffordable
- Resource panel shows current/max/regen

Existing gameplay remains:

- Unit spawning works (when affordable)
- Combat unchanged
- Formation unchanged
- Targeting unchanged
- Death unchanged

Only the validation path changed:
- Before: `PlayCardCommand → SpawnSystem`
- After: `PlayCardCommand → CommandDispatcher → EconomySystem (validate) → SpawnSystem`

End result is identical when resources are available. Commands are rejected when resources are insufficient.
