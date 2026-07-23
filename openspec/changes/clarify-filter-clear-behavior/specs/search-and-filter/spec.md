# search-and-filter delta spec

## Purpose

Clarifies the responsibilities of the clear controls in the search and filter UI. The search-field clear button must clear only the search query. The filter-panel clear button must reset every filter criterion to its default without changing the search query or sort order.

## MODIFIED Requirements

### Requirement: Clear search control

The search field SHALL provide a clear-search button that appears when search text is entered. Tapping it SHALL clear the query only and SHALL NOT modify filters, sort order, or any other view state.

#### Scenario: Clear button resets only search

- **GIVEN** the user has active filters and a sort order
- **WHEN** the user taps the clear-search button
- **THEN** the search field is empty
- **AND** the active filters and sort order remain unchanged

### Requirement: Clear filters control

The filter panel SHALL provide a clear-filters button that resets every filter criterion to its default without changing the search text or sort order.

#### Scenario: Clear filters resets all filter criteria

- **GIVEN** the user has selected collection sub-types
- **AND** the user has set a player-count range
- **AND** the user has added one or more players to the player participation filter
- **WHEN** the user taps the clear-filters button
- **THEN** no sub-type is selected
- **AND** every range slider is at its minimum/maximum default
- **AND** every added player is set to the `any` state
- **AND** the search text remains unchanged
