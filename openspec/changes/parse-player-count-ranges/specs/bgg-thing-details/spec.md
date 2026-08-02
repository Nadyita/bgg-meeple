# bgg-thing-details delta spec

## Purpose

Adds numeric min/max player count fields for best and recommended player counts parsed from the `/xmlapi2/thing` `poll-summary` element. Falls back to computing ranges from the raw `poll` data when the summary is missing.

## MODIFIED Requirements

### Requirement: Parse best player count range from poll summary
The app SHALL parse the `bestwith` value in `poll-summary[@name='suggested_numplayers']` into numeric `bestPlayerCountMin` and `bestPlayerCountMax` values. It SHALL support the forms `X`, `X-Y`, `X+`, and `X-Y+`.

#### Scenario: Single best player count
- **GIVEN** the `bestwith` value is "Best with 3 players"
- **WHEN** the app parses the summary
- **THEN** `bestPlayerCountMin` is 3 and `bestPlayerCountMax` is 3

#### Scenario: Closed best player count range
- **GIVEN** the `bestwith` value is "Best with 4–5 players"
- **WHEN** the app parses the summary
- **THEN** `bestPlayerCountMin` is 4 and `bestPlayerCountMax` is 5

#### Scenario: Open-ended best player count
- **GIVEN** the `bestwith` value is "Best with 5+ players"
- **WHEN** the app parses the summary
- **THEN** `bestPlayerCountMin` is 5 and `bestPlayerCountMax` is null

#### Scenario: Closed open-ended best player count range
- **GIVEN** the `bestwith` value is "Best with 8–18+ players"
- **WHEN** the app parses the summary
- **THEN** `bestPlayerCountMin` is 8 and `bestPlayerCountMax` is null

### Requirement: Parse recommended player count range from poll summary
The app SHALL parse the `recommendedwith` value in `poll-summary[@name='suggested_numplayers']` into numeric `recommendedPlayerCountMin` and `recommendedPlayerCountMax` values, using the same rules as for the best player count.

#### Scenario: Closed recommended range
- **GIVEN** the `recommendedwith` value is "Recommended with 3–7 players"
- **WHEN** the app parses the summary
- **THEN** `recommendedPlayerCountMin` is 3 and `recommendedPlayerCountMax` is 7

#### Scenario: Open-ended recommended range
- **GIVEN** the `recommendedwith` value is "Recommended with 8–18+ players"
- **WHEN** the app parses the summary
- **THEN** `recommendedPlayerCountMin` is 8 and `recommendedPlayerCountMax` is null

### Requirement: Accept different dash characters as range separators
The app SHALL treat en-dash (`–`), em-dash (`—`), and hyphen-minus (`-`) as equivalent range separators when parsing player count ranges.

#### Scenario: En-dash range
- **GIVEN** the summary value contains "4–5"
- **WHEN** the app parses the value
- **THEN** it extracts min 4 and max 5

### Requirement: Fall back to raw poll data when poll-summary is missing
When the `poll-summary` element is absent or does not contain a parseable value, the app SHALL compute best and recommended ranges from the raw `suggested_numplayers` poll.

#### Scenario: Best count fallback
- **GIVEN** no `poll-summary` is present
- **AND** the `poll` shows the highest number of `Best` votes at 4 players
- **WHEN** the app parses the poll
- **THEN** `bestPlayerCountMin` is 4 and `bestPlayerCountMax` is 4

#### Scenario: Recommended range fallback
- **GIVEN** no `poll-summary` is present
- **AND** the `poll` shows `Recommended` share ≥ 50 % for 3, 4, 5, and 6 players
- **WHEN** the app parses the poll
- **THEN** `recommendedPlayerCountMin` is 3 and `recommendedPlayerCountMax` is 6

### Requirement: Store player count ranges in the database
The app SHALL persist `bestPlayerCountMin`, `bestPlayerCountMax`, `recommendedPlayerCountMin`, and `recommendedPlayerCountMax` in the local cache so they can be used for filtering.

#### Scenario: Round-trip persistence
- **GIVEN** a parsed game has best range 4–5 and recommended range 3–7
- **WHEN** the game is saved and reloaded from the cache
- **THEN** all four numeric values are restored correctly
