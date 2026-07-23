# search-and-filter delta spec

## Purpose

Adds a requirement that player participation filters behave correctly when the app restarts. The existing player filter logic must evaluate against cached plays that are loaded together with the persisted view state.

## ADDED Requirements

### Requirement: Player filters work after app restart

When the app restarts and restores a persisted view state that contains active player participation filters, the collection list SHALL show the same games that would be shown if the user had applied the same filters while the app was already running.

#### Scenario: Restart with active player filter

- **GIVEN** the user selected player "Markus" with state `played`
- **AND** the collection contains a game with at least one logged play that includes "Markus"
- **AND** the app was closed and restarted
- **WHEN** the collection screen finishes loading
- **THEN** the game with the logged play is visible
- **AND** the message "No games match your filters." is NOT shown

#### Scenario: Restart with active player filter and play count range

- **GIVEN** the user selected player "Markus" with state `played`
- **AND** the user selected a play-count range from 1 to the maximum
- **AND** a game has two logged plays containing "Markus"
- **AND** the app was closed and restarted
- **WHEN** the collection screen finishes loading
- **THEN** the game is visible because its effective play count is evaluated against the cached plays

### Requirement: Filter evaluation uses loaded plays during initialization

During the initial load of the collection screen, the filter logic SHALL evaluate player participation and play count using the cached plays that were loaded in the same initialization step, not using an empty or stale plays map.

#### Scenario: Empty plays map must not hide matching games on startup

- **GIVEN** the persisted view state contains an active player filter
- **WHEN** the collection screen finishes its first load
- **THEN** the effective play count for each game is computed from the cached plays loaded at startup
- **AND** games that satisfy the filter are shown
