## ADDED Requirements

### Requirement: Tapping a card opens a detail page
Tapping a collection item SHALL open a game detail page showing all known game data including description, categories, mechanics, designers, publishers, and weight.

#### Scenario: Card tap navigates to detail
- **WHEN** the user taps a collection card
- **THEN** the app navigates to the detail page for that game

### Requirement: Detail page shows cached full image behind thumbnail
The detail page SHALL show the game's thumbnail immediately. The full-resolution game image SHALL be loaded lazily and cached locally while the thumbnail is visible.

#### Scenario: Full image loads lazily
- **WHEN** the user opens a detail page
- **THEN** the thumbnail is shown immediately and the full image is loaded and cached in the background

### Requirement: Detail page provides external BGG link
The detail page SHALL provide a link to the corresponding BoardGameGeek page with a clearly identifiable external-link icon.

#### Scenario: External link opens BGG page
- **WHEN** the user taps the external BGG link
- **THEN** the BGG page for the game is opened in an external browser

### Requirement: Detail page shows alternate and localized names
The detail page SHALL display all alternate and localized game names behind a toggle.

#### Scenario: Toggle reveals alternate names
- **WHEN** the user expands the alternate names section
- **THEN** all alternate and localized names for the game are shown

### Requirement: Detail page can be closed in multiple ways
The detail page SHALL be closable via the app-bar back arrow, the Escape key, or the system back button or gesture.

#### Scenario: Escape key closes detail page
- **WHEN** the user presses the Escape key on Linux Desktop
- **THEN** the detail page closes and the collection list is shown
