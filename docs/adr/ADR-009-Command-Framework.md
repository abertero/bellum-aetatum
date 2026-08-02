# ADR-009: Command Framework

## Status

Accepted

## Context

The game previously had direct coupling between input sources and systems. UI elements (BattleScene) directly called SpawnSystem methods, and CombatSystem directly invoked AttackSystem. This created several issues:

1. **Tight coupling**: Input handlers needed direct references to systems
2. **No input abstraction**: Player input, AI decisions, and replay playback would each need separate integration points
3. **Difficult to validate**: No central point to validate or log gameplay requests
4. **No replay support**: Cannot record and playback game sessions without capturing system calls
5. **Limited extensibility**: Adding new input sources (network play, tutorials) requires modifying multiple systems

The Action Framework (ADR-008) established that gameplay operations produce immutable Action objects. However, the request side (input → execution) lacked a similar abstraction.

## Decision

Introduce a Command Framework that separates player intent from gameplay execution:

### Core Components

1. **GameCommand** (base class): Immutable request object containing command_id, timestamp, and metadata
2. **PlayCardCommand**: Request to spawn a unit (card_definition, spawn_position, target_position, parent, team)
3. **AttackCommand**: Request to execute an attack (attacker, target)
4. **CommandDispatcher**: Routes commands to appropriate systems without implementing gameplay logic

### Flow Architecture

```
Input Source (Player/AI/Replay)
    ↓
GameCommand (immutable request)
    ↓
CommandDispatcher (routing only)
    ↓
System (execution)
    ↓
GameAction (result)
    ↓
EventBus (broadcast)
```

### Key Principles

- **Commands are requests**: They express intent but never modify game state
- **Commands are immutable**: Created once with all required data
- **Dispatcher is dumb**: Routes commands but contains no gameplay logic
- **Systems execute**: Only systems modify game state
- **Actions are results**: Systems produce Actions after executing Commands
- **EventBus broadcasts**: Actions flow through EventBus for decoupled observation

### Implementation Details

**GameCommand** (base class):
- `command_id`: Unique identifier for tracking
- `timestamp`: Creation time
- `metadata`: Extensible data dictionary

**PlayCardCommand**:
- `card_definition`: UnitDefinition to spawn
- `spawn_position`: Where to spawn
- `target_position`: Movement destination
- `parent`: Parent node for scene tree
- `team`: "player" or "enemy"

**AttackCommand**:
- `attacker`: UnitInstance performing attack
- `target`: UnitInstance being attacked

**CommandDispatcher**:
- `initialize(spawn_system, attack_system)`: Dependency injection
- `dispatch(command) -> Variant`: Routes to appropriate system
- `_dispatch_play_card(command) -> UnitInstance`: Calls SpawnSystem
- `_dispatch_attack(command) -> DamageAction`: Calls AttackSystem

## Alternatives Considered

### Alternative 1: Direct System Calls (Previous Approach)

Continue with UI calling systems directly.

**Pros**:
- Simpler, fewer layers
- No command object allocation overhead

**Cons**:
- Tight coupling between input and systems
- No central validation point
- Cannot support multiple input sources
- No replay capability
- Difficult to add input validation or logging

**Why Rejected**: The coupling issues and lack of extensibility outweigh the simplicity benefits.

### Alternative 2: Command Pattern with Execute Method

Each command implements an `execute()` method that directly modifies game state.

**Pros**:
- Commands are self-contained
- No dispatcher needed

**Cons**:
- Commands become mutable (they modify state)
- Violates separation of concerns
- Commands need system references
- Harder to validate before execution
- Cannot queue or delay execution

**Why Rejected**: Violates the principle that commands are immutable requests. Systems should own all state modification.

### Alternative 3: EventBus for Commands

Route commands through EventBus like actions.

**Pros**:
- Consistent with action broadcasting
- Decoupled by default

**Cons**:
- Commands are requests (synchronous), actions are results (asynchronous)
- Need to wait for response from system
- Harder to track command completion
- Mixes request/response with broadcast patterns

**Why Rejected**: Commands and actions have different semantics. Commands are synchronous requests that need immediate execution. Actions are asynchronous results that are broadcast for observation.

### Alternative 4: Command Queue with Processing

Queue all commands and process them in a batch each frame.

**Pros**:
- Deterministic ordering
- Can optimize batch processing
- Easier to implement undo/redo

**Cons**:
- Adds latency (commands wait for next frame)
- More complex implementation
- Overkill for current game scope
- Player input feels delayed

**Why Rejected**: The current game doesn't need batch processing. Commands execute immediately for responsive gameplay. Can be added later if needed.

### Alternative 5: Command Handlers per Type

Each command type has a dedicated handler class.

**Pros**:
- Clear separation per command type
- Easy to add new command types

**Cons**:
- More classes to maintain
- Handler proliferation
- Over-engineering for two command types

**Why Rejected**: CommandDispatcher can route commands directly to systems. Handler classes add unnecessary indirection at this scale.

## Consequences

### Positive

1. **Decoupled input**: Input sources (UI, AI, replay) only need to create commands
2. **Central validation**: Dispatcher can validate commands before execution (future enhancement)
3. **Logging support**: All commands flow through one point for logging
4. **Replay foundation**: Commands can be serialized and replayed
5. **AI integration**: AI can generate commands using same interface as player
6. **Network ready**: Commands can be sent over network for multiplayer
7. **Tutorial support**: Tutorials can inject commands to guide players
8. **Testability**: Can test systems by dispatching commands directly
9. **Extensibility**: New command types added without modifying systems
10. **Clear intent**: Commands make gameplay requests explicit

### Negative

1. **Additional layer**: One more abstraction to understand
2. **Object allocation**: Each command creates a RefCounted object (minimal overhead)
3. **Indirection**: Slightly harder to trace command flow during debugging
4. **Type casting**: Dispatcher returns Variant, requires casting to specific action types
5. **Learning curve**: New developers must understand command vs action distinction

### Neutral

1. **No validation yet**: Current dispatcher does not validate commands (future enhancement)
2. **No queuing**: Commands execute immediately (can be added later)
3. **No undo**: Commands are not stored for undo (can be added later)
4. **Systems unchanged**: SpawnSystem and AttackSystem APIs remain the same

## Migration Strategy

### Phase 1: Framework Introduction (Current)

- Add Command Framework layer
- Route player input through commands
- Route combat through commands
- Systems remain unchanged
- Gameplay behavior identical

### Phase 2: Validation (Future)

- Add command validation in dispatcher
- Validate unit is alive before attack
- Validate card can be played (cost, cooldown)
- Return validation errors to caller

### Phase 3: Logging (Future)

- Log all commands through dispatcher
- Track command frequency and patterns
- Debug command flow in development

### Phase 4: Replay (Future)

- Serialize commands to file
- Playback commands in sequence
- Time-stamped replay
- Deterministic simulation

### Phase 5: AI Integration (Future)

- AI generates commands
- Same command interface as player
- AI difficulty via command selection
- AI can use same validation/logging

### Phase 6: Network (Future)

- Send commands over network
- Authoritative server validates
- Clients send commands, receive actions
- Lag compensation via command prediction

## Relationship to Action Framework

The Command Framework complements the Action Framework:

| Aspect | Command | Action |
|--------|---------|--------|
| **Purpose** | Request intent | Report result |
| **Timing** | Before execution | After execution |
| **Mutability** | Immutable | Immutable |
| **Flow** | Input → Dispatcher → System | System → EventBus → Listeners |
| **Direction** | Inward (to systems) | Outward (from systems) |
| **Examples** | PlayCardCommand, AttackCommand | DamageAction, SpawnAction |

**Flow**:
```
Command (request) → System → Action (result) → EventBus
```

## Future Command Types

The framework supports future command types without modification:

- **MoveCommand**: Move unit to position
- **UseAbilityCommand**: Activate unit ability
- **SpawnCommand**: Generic spawn (not card-based)
- **EconomyCommand**: Spend/gain resources
- **EndTurnCommand**: Turn-based game flow

Each command type:
1. Extends GameCommand
2. Contains required data
3. Routed by CommandDispatcher
4. Executed by appropriate system
5. Produces corresponding action

## Verification

Gameplay behavior remains unchanged:

- Unit spawning: Same positions, same timing
- Combat: Same damage calculation, same attack speed
- Formation: Same collision detection, same positioning
- Targeting: Same frontline selection
- Death: Same cleanup and removal

Only the request path changed:
- Before: `BattleScene → SpawnSystem`
- After: `BattleScene → PlayCardCommand → CommandDispatcher → SpawnSystem`

- Before: `CombatSystem → AttackSystem`
- After: `CombatSystem → AttackCommand → CommandDispatcher → AttackSystem`

End result is identical.
