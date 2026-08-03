# collection-list delta spec

## Purpose

Extends the collection card's player count metadata line so it can display the BGG-recommended and BGG-best player counts inline when the user enables the corresponding card layout options.

## ADDED Requirements

### Requirement: Player count line appends recommended count

When the "Show recommended player numbers" card layout option is enabled, the player count metadata line SHALL append the BGG-recommended player count after the regular player count, separated by a visual delimiter and identified by the `Icons.thumb_up` icon.

#### Scenario: Recommended count is shown inline

- **GIVEN** a collection item has a regular player count of "2 - 4 Players"
- **AND** its recommended player count is "3 - 4"
- **AND** the "Show recommended player numbers" option is enabled
- **WHEN** the collection card is rendered
- **THEN** the player count line shows "2 - 4 Players" followed by the thumb-up icon and "3 - 4"

#### Scenario: Missing recommended count is omitted

- **GIVEN** a collection item has no recommended player count
- **AND** the "Show recommended player numbers" option is enabled
- **WHEN** the collection card is rendered
- **THEN** only the regular player count is shown

### Requirement: Player count line appends best count

When the "Show best player numbers" card layout option is enabled, the player count metadata line SHALL append the BGG-best player count after the regular player count, separated by a visual delimiter and identified by the `Icons.emoji_events` icon.

#### Scenario: Best count is shown inline

- **GIVEN** a collection item has a regular player count of "2 - 4 Players"
- **AND** its best player count is "3"
- **AND** the "Show best player numbers" option is enabled
- **WHEN** the collection card is rendered
- **THEN** the player count line shows "2 - 4 Players" followed by the trophy icon and "3"

#### Scenario: Missing best count is omitted

- **GIVEN** a collection item has no best player count
- **AND** the "Show best player numbers" option is enabled
- **WHEN** the collection card is rendered
- **THEN** only the regular player count is shown

### Requirement: Both values can be shown together

When both options are enabled and both values are present, the player count line SHALL show the regular player count followed by the recommended count and then the best count, or in an order that is visually consistent and clearly labeled.

#### Scenario: Both recommended and best are present

- **GIVEN** a collection item has a regular player count of "1 - 5 Players"
- **AND** its recommended player count is "2 - 4"
- **AND** its best player count is "3"
- **AND** both options are enabled
- **WHEN** the collection card is rendered
- **THEN** the player count line includes the regular, recommended, and best values in a readable order

### Requirement: Compact view is unaffected

The compact table-style view SHALL continue to show only the game name and SHALL NOT display player count or its recommended/best values.

#### Scenario: Compact mode stays minimal

- **GIVEN** the user switches to compact view
- **AND** both "Show recommended player numbers" and "Show best player numbers" are enabled
- **WHEN** the collection list is rendered
- **THEN** each row shows only the game name
