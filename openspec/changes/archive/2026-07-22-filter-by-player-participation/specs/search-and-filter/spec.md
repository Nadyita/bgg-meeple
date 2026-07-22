# search-and-filter delta spec

## Purpose

Extends the collection filter panel with per-player participation criteria. A user can add players from known plays and choose, per player, whether their participation is irrelevant, required, or forbidden.

## ADDED Requirements

### Requirement: Filter by player participation

The filter controls SHALL allow the user to add players and, for each added player, choose one of three states:

- `any` (default) — the player's participation does not affect the result.
- `played` — only games where the player has logged at least one play are shown.
- `notPlayed` — only games where the player has not logged any play are shown.

Multiple player filters SHALL be combined with AND logic.

#### Scenario: Show only games a player has played

- **GIVEN** the user added player "Markus" and set the state to played
- **WHEN** the collection list is filtered
- **THEN** only games with at least one logged play containing "Markus" are shown

#### Scenario: Show only games a player has not played

- **GIVEN** the user added player "Markus" and set the state to notPlayed
- **WHEN** the collection list is filtered
- **THEN** only games without any logged play containing "Markus" are shown

#### Scenario: Combine two player filters

- **GIVEN** the user added player "Markus" with state played and player "Anna" with state notPlayed
- **WHEN** the collection list is filtered
- **THEN** only games that Markus has played and Anna has not played are shown

### Requirement: Player filter is empty by default

By default, no player filters SHALL be active. All players are considered `any` until explicitly added and optionally changed to played or notPlayed.

#### Scenario: Default filter panel shows no player chips

- **GIVEN** the user has never added a player filter
- **WHEN** the filter panel is opened
- **THEN** no player chips are shown and only the add-player control is visible

### Requirement: Player name matching is case-insensitive

The filter logic SHALL compare player names case-insensitively. Different casing in logged plays SHALL be treated as the same player.

#### Scenario: Casing in plays does not matter

- **GIVEN** logged plays contain the player name "markus"
- **WHEN** the user adds a filter for "Markus"
- **THEN** the games containing "markus" match the filter

### Requirement: Removed players are omitted from persisted filter

When a player chip is removed from the filter panel, that player's entry SHALL be removed from the persisted filter map.

#### Scenario: Removing a player clears their filter

- **GIVEN** the user added player "Markus"
- **WHEN** the user removes the "Markus" chip
- **THEN** "Markus" is no longer part of the active or persisted filter

### Requirement: Player filters combine with existing filters using AND logic

Player participation filters SHALL be combined with search text, collection sub-types, player count, play time, and rating using AND logic.

#### Scenario: Search and player filter together

- **GIVEN** the user searches for "Catan" and adds a player filter for "Markus" with state played
- **WHEN** the list is updated
- **THEN** only games whose name contains "Catan" and which contain Markus are shown
