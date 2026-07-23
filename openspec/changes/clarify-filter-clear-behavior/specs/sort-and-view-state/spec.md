# sort-and-view-state delta spec

## Purpose

Clarifies that the dedicated view-state reset action clears search text, filters, and sort order together, while the search-field clear button and the filter-panel clear button have narrower responsibilities.

## MODIFIED Requirements

### Requirement: View state reset is available

The app SHALL provide a dedicated way to clear the current view state (search text, filters, and sort order) and return to the default collection view. The search-field clear button SHALL NOT trigger this full reset.

#### Scenario: Clear view state

- **WHEN** the user invokes the dedicated clear-view action
- **THEN** search text, filters, and sort order are reset to defaults

#### Scenario: Search clear does not trigger full view reset

- **GIVEN** the user has active filters and a sort order
- **WHEN** the user taps the search-field clear button
- **THEN** only the search text is cleared
- **AND** filters and sort order remain unchanged
