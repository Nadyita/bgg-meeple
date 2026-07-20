# sort-and-view-state Specification

## Purpose

Defines how the collection list can be sorted and how the user's current view state (search, filters, sort, scroll position) is persisted locally and restored across app restarts.

## Requirements
### Requirement: Collection list can be sorted
The user SHALL be able to sort the collection list by name (default), play time, BGG rating, or year. A toggle SHALL switch between ascending and descending order.

#### Scenario: Sort by play time descending
- **WHEN** the user selects play-time sort order and taps the descending toggle
- **THEN** the collection list is ordered by play time from highest to lowest

### Requirement: View state is persisted locally
The current search text, active filters, sort order, and scroll position SHALL be persisted locally and restored when the app restarts. This SHALL be the only device-local state; game data SHALL remain identical across devices after sync.

#### Scenario: Restart restores previous view state
- **WHEN** the user sets search text, filters, and sort order and then restarts the app
- **THEN** the app restores the same search text, filters, sort order, and scroll position

### Requirement: View state reset is available
The app SHALL provide a way to clear the current view state (search text, filters, and sort order) and return to the default collection view.

#### Scenario: Clear view state
- **WHEN** the user invokes the clear-view action
- **THEN** search text, filters, and sort order are reset to defaults

