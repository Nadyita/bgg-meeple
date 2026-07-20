## ADDED Requirements

### Requirement: Card fields are configurable and reorderable
The settings screen SHALL allow the user to choose which values appear on each collection card. Configurable fields SHALL include thumbnail, version subtitle, player count, play time, plays (with "Hide on 0"), own rating, geek rating (with optional number of ratings), min age, and BGG rank. All fields except title and sub-type chips SHALL be toggleable, and most fields SHALL be reorderable via drag-and-drop.

#### Scenario: User customizes card fields
- **WHEN** the user enables, disables, and reorders card fields in settings
- **THEN** the collection cards reflect the selected fields in the chosen order

### Requirement: Plays and geek rating fields show optional hints
The card layout settings SHALL indicate when the plays field is hidden at zero and when the geek rating can include the number of ratings.

#### Scenario: Plays hidden on zero
- **WHEN** the plays field is configured to hide on zero and a game has zero recorded plays
- **THEN** the plays field is not shown on that card

### Requirement: Card metadata fields use dedicated icons
Selected card metadata fields SHALL be displayed with dedicated icons similar to the reference design (player icon, clock icon, etc.).

#### Scenario: Metadata icons render
- **WHEN** the collection list shows cards with metadata fields enabled
- **THEN** each metadata value appears next to a relevant icon

### Requirement: Font size setting applies app-wide
The settings screen SHALL offer 5 text size levels where the middle level corresponds to the normal default text size. The selected level SHALL apply app-wide and SHALL persist across app restarts.

#### Scenario: Font size persists
- **WHEN** the user selects a larger font size and restarts the app
- **THEN** text is rendered at the selected larger size after restart
