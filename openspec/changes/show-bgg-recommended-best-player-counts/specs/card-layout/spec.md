# card-layout delta spec

## Purpose

Adds two card-layout toggles that control whether BGG-recommended and BGG-best player counts are rendered inline with the regular player count on collection cards.

## ADDED Requirements

### Requirement: Toggle for recommended player numbers

The card layout settings SHALL provide a toggle labeled "Show recommended player numbers" that is off by default. When enabled and the player count field is shown, the BGG-recommended player count is appended to the player count line on each collection card.

#### Scenario: Enable recommended player numbers

- **GIVEN** the player count field is enabled in the card layout
- **AND** the "Show recommended player numbers" toggle is turned on
- **WHEN** a collection card is rendered for a game with a recommended player count
- **THEN** the player count line includes the recommended player count

#### Scenario: Recommended toggle is off by default

- **GIVEN** the user has never changed the card layout settings
- **WHEN** the settings screen is opened
- **THEN** the "Show recommended player numbers" toggle is off

### Requirement: Toggle for best player numbers

The card layout settings SHALL provide a toggle labeled "Show best player numbers" that is off by default. When enabled and the player count field is shown, the BGG-best player count is appended to the player count line on each collection card.

#### Scenario: Enable best player numbers

- **GIVEN** the player count field is enabled in the card layout
- **AND** the "Show best player numbers" toggle is turned on
- **WHEN** a collection card is rendered for a game with a best player count
- **THEN** the player count line includes the best player count

#### Scenario: Best toggle is off by default

- **GIVEN** the user has never changed the card layout settings
- **WHEN** the settings screen is opened
- **THEN** the "Show best player numbers" toggle is off

### Requirement: Recommended and best values only augment the player count line

The recommended and best player number values SHALL only appear on the player count metadata line. They SHALL NOT create additional metadata lines and SHALL NOT appear when the player count field is disabled.

#### Scenario: Player count field disabled

- **GIVEN** the player count field is disabled in the card layout
- **AND** both "Show recommended player numbers" and "Show best player numbers" are enabled
- **WHEN** a collection card is rendered
- **THEN** no player count information is shown on the card

## MODIFIED Requirements

### Requirement: Card layout settings persist toggles

The existing card layout persistence SHALL also store and restore the two new toggles so the chosen display mode survives app restarts.

#### Scenario: Toggles persist after restart

- **GIVEN** the user enabled both "Show recommended player numbers" and "Show best player numbers"
- **WHEN** the app is fully closed and reopened
- **THEN** both toggles are still enabled and the player count line still shows the values
