# search-and-filter Specification

## Purpose

Defines the live search and filter behavior on the main collection screen, including the expandable filter panel, combined AND filtering across search, sub-types, player count, play time, rating ranges, and play count.
## Requirements
### Requirement: Live search by game name
A search field at the top of the main list SHALL filter the collection by game name as the user types. The search SHALL be case-insensitive and SHALL only match game names (custom name and BGG names), not version edition names.

#### Scenario: Typing filters list immediately
- **WHEN** the user types text into the search field
- **THEN** the collection list updates immediately to show only games whose names contain the typed text

### Requirement: Clear search control
The search field SHALL provide a clear-search button that appears when search text is entered. Tapping it SHALL clear the query and the persisted view state.

#### Scenario: Clear button resets search
- **WHEN** the user taps the clear-search button
- **THEN** the search field is empty and the full collection list is shown

### Requirement: Expandable filter panel
A filter icon next to the search field SHALL expand and collapse additional filter controls for player count, play time range, rating, play count, and collection sub-types.

#### Scenario: Filter icon toggles panel
- **WHEN** the user taps the filter icon
- **THEN** the additional filter controls expand or collapse

### Requirement: Filter by collection sub-type
The filter controls SHALL allow selecting which BGG collection sub-types to show. All sub-types SHALL be shown by default. When multiple sub-types are selected, OR logic SHALL apply.

#### Scenario: Multiple selected sub-types use OR logic
- **WHEN** the user selects "owned" and "wishlist"
- **THEN** the list shows items that are owned OR wishlisted

### Requirement: Filter by player count range
The filter controls SHALL provide a two-handle range slider from 1 to 16 players. Only games whose player range overlaps the selected range SHALL be shown, and the list SHALL update immediately.

#### Scenario: Player range overlap filter
- **WHEN** the user selects a player-count range of 3 to 5
- **THEN** the list shows only games that can be played by 3 to 5 players according to their supported player range

### Requirement: Filter by play time range
The filter controls SHALL provide a two-handle range slider with discrete steps (0, 5, 10, 15, 30, 45, 60, 90, 120, 240, 360, 480, 720 minutes). The filter SHALL apply against the effective play time (`maxplaytime` or `minplaytime`), and the list SHALL update immediately.

#### Scenario: Play time range filter
- **WHEN** the user selects a play-time range
- **THEN** the list shows only games whose effective play time falls within the selected range

### Requirement: Filter by own or BGG rating range

The filter controls SHALL provide a two-handle range slider from 0 to 10 in 0.5 steps. The effective rating SHALL be the user's own rating when set, otherwise `bayesaverage`. Only games whose effective rating falls within the selected range SHALL be shown, and the list SHALL update immediately.

#### Scenario: Rating range filter

- **WHEN** the user selects a rating range of 7.0 to 10.0
- **THEN** only games whose effective rating falls within 7.0 to 10.0 are shown

#### Scenario: Rating filter prefers own rating

- **GIVEN** a game has an own rating of 6.0 and a `bayesaverage` of 8.0
- **WHEN** the user selects a rating range of 7.0 to 10.0
- **THEN** the game is not shown because its effective rating is the own rating

### Requirement: Filter by play count range
The filter controls SHALL provide a two-handle range slider from 0 to the maximum `numplays` value among all loaded collection items. The effective play count SHALL be the collection item's `numplays` when no player participation filter is active. When player participation filters are active, the effective play count SHALL be the number of logged plays for the game whose player set satisfies the configured player participation rules. Only games whose effective play count falls within the selected range SHALL be shown, and the list SHALL update immediately.

#### Scenario: Filter by total plays
- **GIVEN** a game has `numplays` of 5 and no player participation filter is active
- **WHEN** the user selects a play-count range of 1 to 10
- **THEN** the game is shown

#### Scenario: Filter by plays with specific players
- **GIVEN** a game has three logged plays: Play 1 contains "Dine", Play 2 contains "Dine" and "Mark", Play 3 contains "Mark"
- **AND** the user filters for "Dine" = played and "Mark" = not played
- **WHEN** the user selects a play-count range of 1 to 1
- **THEN** only Play 1 satisfies the player filter, so the game is shown

#### Scenario: Player participation and play count filter combined
- **GIVEN** the user adds player "Dine" with state played
- **AND** the user selects a play-count range from 2 to its maximum
- **WHEN** the collection is filtered
- **THEN** only games where Dine appears in at least two logged plays are shown

#### Scenario: Play count slider maximum uses all loaded items
- **GIVEN** the loaded collection contains items with `numplays` of 0, 3, and 12
- **WHEN** the filter panel is opened
- **THEN** the play-count slider maximum is 12 and the minimum is 0

#### Scenario: Rating filter prefers own rating
- **WHEN** the user has rated a game and selects a rating range
- **THEN** the game is included or excluded based on the user's own rating

### Requirement: Combined filters use AND logic
Multiple active filters and search text SHALL be combined with AND logic. The list SHALL update immediately whenever any criterion changes.

#### Scenario: Search plus filters combine with AND
- **WHEN** the user enters search text and activates a sub-type filter
- **THEN** only items that match both the search text and the selected sub-type are shown

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

Player participation filters SHALL be combined with search text, collection sub-types, player count, play time, rating, and play count using AND logic.

#### Scenario: Search and player filter together

- **GIVEN** the user searches for "Catan" and adds a player filter for "Markus" with state played
- **WHEN** the list is updated
- **THEN** only games whose name contains "Catan" and which contain Markus are shown

