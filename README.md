# Bellum Aetatum

A strategy game inspired by Battle Cats, auto battlers, and collectible card games.

Players build a deck before entering battle. Units are represented by cards. The battlefield contains two bases. Players summon units from their deck.

## Vision

Everything in the game should be configurable without changing source code. The engine interprets data instead of hardcoding it.

## Tech Stack

- **Engine:** Godot 4.4
- **Language:** GDScript (typed)
- **Data Format:** JSON

## Project Structure

```
res://
    scenes/              # Scene files (.tscn)
    scripts/             # Gameplay scripts
    data/
        cards/           # Card database (cards.json)
        decks/           # Deck definitions (player_deck.json, enemy_deck.json)
        stages/          # Stage configurations (stage_001.json)
    assets/
        cards/           # Card artwork (future)
    autoload/            # Singleton scripts (JsonLoader, DeckManager)
```

## Architecture

### Classes

| Class | Type | Responsibility |
|---|---|---|
| `JsonLoader` | Autoload | Reads and parses JSON files |
| `DeckManager` | Autoload | Loads card database and builds decks |
| `SpawnManager` | RefCounted | Instantiates Unit scenes from card data |
| `Unit` | Node2D | Represents one spawned unit on the battlefield |
| `BattleScene` | Node2D | Coordinates the current milestone |

### Communication Flow

```
BattleScene
  -> JsonLoader (reads JSON)
  -> DeckManager (loads decks via JsonLoader)
  -> SpawnManager (spawns units into scene)
  -> Unit (receives card data, displays visuals)
```

## Architecture Rules

- Every class should remain under 250 lines.
- Every function should remain under 30 lines.
- Avoid static methods unless they are pure utility functions.
- Prefer signals over tight coupling.
- Every scene should have a single responsibility.
- Every script should be reusable.
- Never duplicate JSON parsing logic.
- Never hardcode game values.
- Prefer factories instead of switch statements.
- Keep dependencies pointing inward.

## SOLID Principles

- **Single Responsibility:** Each class has one reason to change. JsonLoader only reads files. DeckManager only resolves decks. SpawnManager only creates units.
- **Open/Closed:** New cards are added via JSON, not code. New stages require only a new JSON file.
- **Liskov Substitution:** Unit can be extended without breaking the SpawnManager contract.
- **Interface Segregation:** Classes depend only on the data they consume (Dictionary contracts).
- **Dependency Inversion:** BattleScene depends on abstractions (JsonLoader, DeckManager, SpawnManager), not on concrete data or scenes.

## Running the Project

1. Open Godot 4.4.
2. Import the project from this directory.
3. Run the main scene (`scenes/battle_scene.tscn`).

## Milestones

- [x] Milestone 1 — Architecture validation (see `MILESTONE_1.md`)
