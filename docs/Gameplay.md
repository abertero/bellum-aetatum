# Gameplay

## Core Loop

Players build a deck before entering battle. Units are represented by cards. The battlefield contains two bases (nexus). Players summon units from their deck to destroy the enemy nexus.

## Pre-Battle

1. Player selects a deck (card list referencing cards.json)
2. Game mode is selected (references game_modes.json)
3. Stage is loaded (stage_001.json defines battlefield dimensions and spawn positions)
4. Match rules are loaded (match_rules.json defines countdown, time limit, victory conditions)

## Match Flow

### 1. Loading Phase
- All systems initialize
- Decks are loaded from JSON
- AI personality is loaded based on game mode

### 2. Countdown Phase
- 3-second countdown before gameplay begins
- No gameplay actions allowed

### 3. Running Phase
- Resources regenerate each second (Imperium: +1/s, max 20, start 5)
- Player clicks card buttons to spawn units
- AI evaluates the battlefield every 1.5 seconds and generates commands
- Units move from spawn toward enemy base
- Collision detection forms BattleGroups
- TargetingSystem assigns frontline targets
- CombatSystem resolves attacks (melee and ranged)
- Abilities trigger on unit spawn or manually
- Effects apply combat modifiers
- Projectiles fly and collide

### 4. Victory/Defeat/Draw
- Enemy nexus destroyed -> Victory
- Player nexus destroyed -> Defeat
- Time limit reached -> Draw

## Player Actions

### Spawn Unit
1. Player clicks a card button
2. BattleScene creates PlayCardCommand
3. CommandDispatcher validates against EconomySystem
4. If affordable: resources spent, SpawnSystem creates unit
5. Unit moves toward enemy base

### Use Ability
1. Player clicks ability button
2. AbilitySystem validates cooldown
3. Pipeline executes components sequentially
4. Components may apply effects, spawn projectiles, or generate commands

## AI Actions

### Decision Cycle (every 1.5 seconds)
1. **Perception**: PerceptionSystem reads WorldState from game systems
2. **Evaluation**: EvaluationSystem scores possible actions using personality weights
3. **Decision**: DecisionSystem selects highest-scoring action
4. **Command Generation**: AICommandGenerator creates PlayCardCommand or AbilityCommand
5. **Dispatch**: Command flows through CommandDispatcher (same as player)

### AI Personality Influence
- **evaluation_weights**: How much each action type is valued
- **resource_strategy**: Whether AI saves or spends resources
- **spawn_preferences**: Preferred attack models (melee/ranged)
- **preferred_affinities**: Preferred elemental affinities
- **risk_tolerance**: How aggressively AI commits resources

## Combat Resolution

### Melee Combat
1. Unit reaches frontline, assigned target
2. Attack timer expires (based on attack_speed)
3. AttackCommand dispatched
4. MeleeAttackModel calculates damage
5. AffinityRuleSystem provides modifiers
6. EffectSystem provides modifiers
7. Final damage applied to target HP

### Ranged Combat
1. Unit reaches frontline, assigned target
2. Attack timer expires
3. AttackCommand dispatched
4. RangedAttackModel spawns projectile
5. ProjectileSystem moves projectile
6. CollisionSystem detects impact
7. Damage applied to target HP

## Effects

Effects apply CombatModifiers to units:
- **Strength**: +10% attack damage (STACK)
- **Shield**: -10% incoming damage (STACK)

Modifiers are merged from affinity rules and active effects, then applied in priority order.

## Resource Management

- **Imperium**: Primary resource
  - Maximum: 20
  - Starting: 5
  - Regeneration: 1.0/second
  - Spent on unit cards (cost varies by card)

## Deterministic Simulation

The simulation is deterministic: the same initial state, random seed, and command sequence always produce the same result.

### Fixed Timestep

The simulation runs at a fixed 30 ticks/second, independent of rendering FPS. Frame time accumulates in SimulationContext; each fixed tick is consumed and systems advance. This ensures identical behavior regardless of frame rate.

### Deterministic Randomness

All gameplay randomness flows through `DeterministicRandom`, seeded from `SimulationContext`. This includes:
- AI spawn position offsets
- Player spawn position offsets
- Any future gameplay random values

### Command Authority

Commands are the authoritative input. Both player and AI commands are recorded in `CommandLog` with tick and sequence number. Replay replays the exact same command sequence through the same systems.

### Replay

A match can be reproduced from:
1. Initial MatchSnapshot
2. GameMode
3. Content Version
4. Random Seed
5. Ordered CommandLog

`ReplayPlayer` restores initial state, seeds the random generator, and feeds commands to the existing systems. No separate simulation engine is needed.

### Schema Versioning

All JSON data files include `schema_version`. Replays store the content version used during recording. Incompatible content versions are rejected with a clear diagnostic.
