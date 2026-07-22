# collection-card-plays-players Specification

## Purpose

Defines the optional display of all-time player names inside the `Plays` field on
collection cards.

## Requirements

### Requirement: Player names can be shown behind the play count

The collection card SHALL offer an option that appends the comma-separated list
of all unique player names who ever played this game to the `Plays` count.

#### Scenario: Names are shown when the option is enabled

- **GIVEN** the user enabled the player-name option in the card layout
- **AND** cached plays exist for the displayed game with players named `Mark`,
  `Dine`, and `Eva`
- **WHEN** the collection card is rendered
- **THEN** the `Plays` field reads `Plays: 2 — Dine, Eva, Mark`

### Requirement: Player names are unique and sorted alphabetically

The displayed player list SHALL contain each player name only once and SHALL be
sorted case-insensitive ascending by name.

#### Scenario: Duplicate and unsorted names are normalized

- **GIVEN** cached plays contain players `Mark`, `Dine`, `Eva`, `Dine`, and `mark`
- **WHEN** the card renders the player list
- **THEN** it shows `Dine, Eva, Mark` (case-insensitive unique sort)

### Requirement: Empty or missing player names are ignored

Players that have no name SHALL NOT appear in the list and SHALL NOT create
empty entries or extra commas.

#### Scenario: Anonymous players are filtered out

- **GIVEN** cached plays contain players with names `Dine`, `Mark`, and `null`
- **WHEN** the card renders the player list
- **THEN** it shows `Dine, Mark`

### Requirement: The option is independent from "hide when zero"

The user SHALL be able to enable player names regardless of whether `Plays` is
hidden when the count is zero.

#### Scenario: Hide-when-zero and player names coexist

- **GIVEN** the user enabled both `hidePlaysOnZero` and the player-name option
- **WHEN** a game has zero plays
- **THEN** the `Plays` field is hidden, including any player-name suffix

### Requirement: No player-name suffix without cached plays

When no cached plays exist for a game, the `Plays` field SHALL NOT show a
player-name suffix even if the option is enabled.

#### Scenario: Game without play history

- **GIVEN** the user enabled the player-name option
- **AND** the game has no cached plays
- **WHEN** the card is rendered
- **THEN** the `Plays` field shows only the count or is hidden according to the
  existing `hidePlaysOnZero` rule
