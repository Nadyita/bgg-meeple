# card-layout delta spec

## Purpose

Documents that the player count filter mode is a search-and-filter concern and does not change the card layout toggles for displaying recommended/best player counts.

## ADDED Requirements

### Requirement: Player count filter mode is a view state concern

The player count filter mode SHALL be persisted as part of the collection view state, not as part of the card layout configuration.

#### Scenario: Mode persists with filters and sort

- **GIVEN** the user selected `best` as the player count filter mode
- **WHEN** the app saves the collection view state
- **THEN** the mode is stored alongside search text, filters, and sort order

### Requirement: Card layout toggles remain independent of filter mode

The existing settings toggles for showing recommended and best player counts on collection cards SHALL continue to work independently of the player count filter mode.

#### Scenario: Filter mode does not affect card display toggles

- **GIVEN** the user enabled "Show best player count" in settings
- **AND** the user selected `recommended` in the player count filter
- **WHEN** the collection list is rendered
- **THEN** cards still show the best player count inline when the setting is enabled
