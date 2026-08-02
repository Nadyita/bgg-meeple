# bgg-thing-details delta spec

## Purpose

Extends the `/xmlapi2/thing` player-count parsing so it can handle `poll-summary` values that contain a comma-separated list of counts or ranges, preserving the original text for display while deriving numeric min/max bounds.

## MODIFIED Requirements

### Requirement: Parse best player count from poll summary
The app SHALL parse the `bestwith` value in `poll-summary[@name='suggested_numplayers']` into a textual `bestPlayerCount` value and numeric `bestPlayerCountMin` and `bestPlayerCountMax` values. It SHALL support the forms `X`, `X-Y`, `X+`, `X-Y+`, and comma-separated lists of these forms.

#### Scenario: Single best player count
- **GIVEN** the `bestwith` value is "Best with 4 players"
- **WHEN** the app parses the summary
- **THEN** `bestPlayerCount` is "4"
- **AND** `bestPlayerCountMin` is 4 and `bestPlayerCountMax` is 4

#### Scenario: Closed best player count range
- **GIVEN** the `bestwith` value is "Best with 4–5 players"
- **WHEN** the app parses the summary
- **THEN** `bestPlayerCount` is "4-5"
- **AND** `bestPlayerCountMin` is 4 and `bestPlayerCountMax` is 5

#### Scenario: Open-ended best player count
- **GIVEN** the `bestwith` value is "Best with 5+ players"
- **WHEN** the app parses the summary
- **THEN** `bestPlayerCount` is "5+"
- **AND** `bestPlayerCountMin` is 5 and `bestPlayerCountMax` is null

#### Scenario: Closed open-ended best player count range
- **GIVEN** the `bestwith` value is "Best with 8–18+ players"
- **WHEN** the app parses the summary
- **THEN** `bestPlayerCount` is "8-18+"
- **AND** `bestPlayerCountMin` is 8 and `bestPlayerCountMax` is null

#### Scenario: Comma-separated list of best player counts
- **GIVEN** the `bestwith` value is "Best with 6, 8 players"
- **WHEN** the app parses the summary
- **THEN** `bestPlayerCount` is "6, 8"
- **AND** `bestPlayerCountMin` is 6 and `bestPlayerCountMax` is 8

### Requirement: Parse recommended player count from poll summary
The app SHALL parse the `recommendedwith` value in `poll-summary[@name='suggested_numplayers']` into a textual `recommendedPlayerCount` value and numeric `recommendedPlayerCountMin` and `recommendedPlayerCountMax` values, using the same rules as for the best player count.

#### Scenario: Closed recommended range
- **GIVEN** the `recommendedwith` value is "Recommended with 3–7 players"
- **WHEN** the app parses the summary
- **THEN** `recommendedPlayerCount` is "3-7"
- **AND** `recommendedPlayerCountMin` is 3 and `recommendedPlayerCountMax` is 7

#### Scenario: Open-ended recommended range
- **GIVEN** the `recommendedwith` value is "Recommended with 8—18+ players"
- **WHEN** the app parses the summary
- **THEN** `recommendedPlayerCount` is "8-18+"
- **AND** `recommendedPlayerCountMin` is 8 and `recommendedPlayerCountMax` is null

#### Scenario: Comma-separated mixed recommended list
- **GIVEN** the `recommendedwith` value is "Recommended with 4, 6–10, 12 players"
- **WHEN** the app parses the summary
- **THEN** `recommendedPlayerCount` is "4, 6-10, 12"
- **AND** `recommendedPlayerCountMin` is 4 and `recommendedPlayerCountMax` is 12

### Requirement: Accept different dash characters as range separators
The app SHALL treat en-dash (`–`), em-dash (`—`), and hyphen-minus (`-`) as equivalent range separators when parsing player count ranges.

#### Scenario: En-dash range
- **GIVEN** the summary value contains "4–5"
- **WHEN** the app parses the value
- **THEN** it extracts min 4 and max 5
