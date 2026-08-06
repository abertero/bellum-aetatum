# ADR-015: AI Decision Engine

## Status

Accepted.

## Context

The game requires an AI opponent that plays using the same gameplay pipeline as the player. Without a dedicated AI layer:
- Enemy behavior is hardcoded in BattleScene (timer-based sequential spawning)
- AI cannot use abilities, react to game state, or follow strategies
- No way to vary AI behavior between game modes
- AI personalities cannot be configured without code changes
- The architecture lacks a clean separation between AI perception, evaluation, and action

The existing architecture already provides:
- Command Pattern (PlayCardCommand, AttackCommand, CommandDispatcher) for gameplay actions
- SpatialQuerySystem for read-only battlefield queries
- EconomySystem for resource management
- AbilitySystem for ability execution
- EventBus for decoupled communication
- Definition/Registry/Loader pattern for data-driven content

## Decision

Introduce an AI Decision Engine with four layers: Perception, Evaluation, Decision, and Command Generation. AI personalities are pure data loaded from JSON.

### WorldState

Read-only data snapshot that the AI uses to perceive the world. Contains:
- Friendly and enemy unit lists
- Resource state (current, maximum, regen rate)
- Available and affordable cards
- Ability cooldowns
- Nexus HP ratios
- Match state and elapsed time
- Battlefield dimensions and spawn positions
- Affinity distribution

Populated by PerceptionSystem from existing game systems. Never modifies game state.

### PerceptionSystem

Reads from existing game systems (SpatialQuerySystem, EconomySystem, NexusSystem, AbilitySystem) and produces a WorldState snapshot. The AI's only window into the game world. Never inspects UI.

### EvaluationSystem

Calculates weighted scores for possible actions using the personality's evaluation_weights. Initially evaluates:
- **Spawn Unit**: Scored by card stats, strategic need, affinity preference, spawn preference
- **Use Ability**: Scored by strategic need and personality weight
- **Save Resources**: Scored by resource ratio and resource strategy

Weights come from AIPersonalityDefinition, making behavior fully data-driven.

### DecisionSystem

Selects the highest-scoring evaluation result. Future milestones may replace this with Utility AI, GOAP, Behavior Trees, or Monte Carlo Search without modifying other layers.

### AICommandGenerator

Converts a decision into a gameplay Command (PlayCardCommand or AbilityCommand). Uses the same spawn position calculation and command creation as the player. Commands flow through CommandDispatcher identically.

### AbilityCommand

New command type for ability usage. Carries ability_id, caster, and optional target. Routed by CommandDispatcher to AbilitySystem. Allows AI to use abilities through the same pipeline as the player.

### AIPersonalityDefinition

Pure data container loaded from JSON. Defines:
- evaluation_weights: Dictionary of action type to weight
- resource_strategy: "balanced", "save", or "spend"
- spawn_preferences: Array of preferred attack models
- preferred_affinities: Array of preferred affinity IDs
- risk_tolerance: Float from 0.0 to 1.0

### AIRegistry / AILoader

Follow the existing Registry/Loader pattern. AIRegistry stores personalities by ID. AILoader reads from `data/ai_personalities.json`.

### GameModeDefinition

References a default AI personality by ID. Different game modes can use different personalities. Loaded from `data/game_modes.json`.

### AIDecisionEngine

Orchestrates the decision cycle: Perception -> Evaluation -> Decision -> Command Generation. Runs on a configurable interval (1.5s). Emits events through EventBus.

### AI Personalities

Seven initial personalities:
- **Balanced**: Equal weights, moderate risk
- **Aggressive**: High spawn weight, spend strategy, fire affinity
- **Defensive**: High save weight, save strategy, earth affinity
- **Economic**: Maximum save weight, save strategy, light affinity
- **Rush**: Maximum spawn weight, spend everything, no abilities
- **Swarm**: High spawn weight, many cheap units, dark affinity
- **Legend Hunter**: High ability weight, balanced resources, water/light affinity

## Alternatives Considered

### 1. Hardcoded AI in BattleScene
AI logic could remain in BattleScene as it was for enemy spawning. Rejected because it violates SRP, cannot be reused across game modes, and cannot be configured without code changes.

### 2. AI modifies WorldState directly
AI could directly set enemy unit HP, resources, or positions. Rejected because it bypasses the Command Pattern, breaks consistency, and makes replay/deterministic simulation impossible.

### 3. Inheritance-based AI personalities
Different AI types could use class inheritance. Rejected because composition with data-driven weights is more flexible. New personalities need zero code changes.

### 4. Behavior Trees
AI decisions could use a Behavior Tree framework. Rejected for now as it adds complexity prematurely. The weighted evaluation approach is sufficient for initial AI. Future milestones can introduce BTs by replacing DecisionSystem.

### 5. AI uses separate command types
AI could have its own SpawnAIUnitCommand. Rejected because it duplicates gameplay logic. The AI must use the same PlayCardCommand and AbilityCommand as the player to ensure identical gameplay pipeline execution.

## Consequences

### Positive
- AI uses the exact same Commands as the player (PlayCardCommand, AbilityCommand)
- AI never modifies WorldState directly
- AI personalities are pure data loaded from JSON
- New personalities can be added without writing code
- Open/Closed Principle preserved: new action types extend EvaluationSystem
- DecisionSystem can be replaced with advanced algorithms without changing other layers
- AI debug panel provides full visibility into decision process
- Game modes reference AI personalities by ID for flexible configuration

### Negative
- AIDecisionEngine adds another system to initialize in BattleScene
- PerceptionSystem creates a new WorldState snapshot each cycle (minor allocation)
- battle_scene.gd grows to accommodate AI setup and debug UI

### Risks
- PerceptionSystem must be initialized after all game systems it reads from
- EvaluationSystem weights need tuning to produce reasonable behavior
- AI decision interval (1.5s) may need adjustment for different game modes

## Migration Strategy

The hardcoded enemy spawn timer (`_update_enemy_spawn_timer`, `_spawn_enemy_unit`) is replaced by `_update_ai` which calls `AIDecisionEngine.update()`. The AI generates PlayCardCommand through CommandDispatcher, exactly like the player.

CommandDispatcher gains optional AbilitySystem reference via `set_ability_system()`. Existing PlayCardCommand and AttackCommand routing is unchanged.

## Files Created

| File | Purpose |
|---|---|
| `ai/WorldState.gd` | Read-only world snapshot for AI |
| `ai/PerceptionSystem.gd` | Populates WorldState from game systems |
| `ai/EvaluationSystem.gd` | Calculates weighted action scores |
| `ai/DecisionSystem.gd` | Selects highest-scoring action |
| `ai/AICommandGenerator.gd` | Converts decisions to Commands |
| `ai/AIDecisionEngine.gd` | Orchestrates AI decision cycle |
| `ai/AIRegistry.gd` | Stores AI personalities by ID |
| `ai/AILoader.gd` | Loads personalities from JSON |
| `ai/AIEvaluationResult.gd` | Evaluation result data container |
| `ai/AIDebugData.gd` | Debug data for AI UI |
| `definitions/AIPersonalityDefinition.gd` | AI personality data container |
| `definitions/GameModeDefinition.gd` | Game mode data container |
| `commands/AbilityCommand.gd` | Command for ability usage |
| `data/ai_personalities.json` | AI personality configurations |
| `data/game_modes.json` | Game mode configurations |
| `docs/adr/ADR-015-AI-Decision-Engine.md` | This ADR |

## Files Modified

| File | Changes |
|---|---|
| `core/EventBus.gd` | Added 3 AI signals |
| `commands/CommandDispatcher.gd` | Added AbilityCommand routing, optional AbilitySystem |
| `scenes/battle_scene.gd` | Replaced enemy spawn timer with AI engine, added AI debug panel |
| `README.md` | Updated with AI layer documentation |
| `docs/Architecture.md` | Updated with AI layer and signal flow |
| `docs/Gameplay.md` | Created with AI gameplay flow |
| `MILESTONES.md` | Updated with milestone 15 |
