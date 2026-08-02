# bgg-thing-details delta spec

## Purpose

Extends the `/xmlapi2/thing` player-count parsing so it can handle `poll-summary` values that contain a comma-separated list of counts or ranges, preserving the original text for display while deriving numeric min/max bounds.

## MODIFIED Requirements

### Requirement: Parse comma-separated player count lists in poll summaries
The app SHALL parse `bestwith` and `recommmendedwith` values in `poll-summary[@name='suggested_numplayers']` that contain one or more player-count expressions separated by commas, mixed ranges, and open-ended values.

#### Scenario: List of single player counts
- **GIVEN** the `bestwith` value is "Best with 6, 8 players"
- **WHEN** the app parses the summary
- **THEN** `bestPlayerCount` is "6, 8"
- **AND** `bestPlayerCountMin` is 6
- **AND** `bestPlayerCountMax` is 8

#### Scenario: Mixed list of single values and ranges
- **GIVEN** the `recommmendedwith` value is "Recommended with 4, 6–10, 12 players"
- **WHEN** the app parses the summary
- **THEN** `recommendedPlayerCount` is "4, 6-10, 12"
- **AND** `recommendedPlayerCountMin` is 4
- **AND** `recommendedPlayerCountMax` is 12

#### Scenario: Open-ended value in a list
- **GIVEN** the `recommmendedwith` value is "Recommended with 4, 6+ players"
- **WHEN** the app parses the summary
- **THEN** `recommendedPlayerCount` is "4, 6+"
- **AND** `recommendedPlayerCountMin` is 4
- **AND** `recommendedPlayerCountMax` is null

#### Scenario: Range with plus in a list
- **GIVEN** the `bestwith` value is "Best with 8-10+, 12 players"
- **WHEN** the app parses the summary
- **THEN** `bestPlayerCount` is "8-10+, 12"
- **AND** `bestPlayerCountMin` is 8
- **AND** `bestPlayerCountMax` is null
