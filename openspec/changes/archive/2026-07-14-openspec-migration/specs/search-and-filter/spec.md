## ADDED Requirements

### Requirement: Live search by game name
A search field at the top of the main list SHALL filter the collection by game name as the user types. The search SHALL be case-insensitive and SHALL only match game names (custom name and BGG names), not version edition names.

#### Scenario: Typing filters list immediately
- **WHEN** the user types text into the search field
- **THEN** the collection list updates immediately to show only games whose names contain the typed text

### Requirement: Clear search control
The search field SHALL provide a clear-search button that appears when search text is entered. Tapping it SHALL clear the query and the persisted view state.

#### Scenario: Clear button resets search
- **WHEN** the user taps the clear-search button
- **THEN** the search field is empty and the full collection list is shown

### Requirement: Expandable filter panel
A filter icon next to the search field SHALL expand and collapse additional filter controls for player count, play time range, rating, and collection sub-types.

#### Scenario: Filter icon toggles panel
- **WHEN** the user taps the filter icon
- **THEN** the additional filter controls expand or collapse

### Requirement: Filter by collection sub-type
The filter controls SHALL allow selecting which BGG collection sub-types to show. All sub-types SHALL be shown by default. When multiple sub-types are selected, OR logic SHALL apply.

#### Scenario: Multiple selected sub-types use OR logic
- **WHEN** the user selects "owned" and "wishlist"
- **THEN** the list shows items that are owned OR wishlisted

### Requirement: Filter by player count range
The filter controls SHALL provide a two-handle range slider from 1 to 16 players. Only games whose player range overlaps the selected range SHALL be shown, and the list SHALL update immediately.

#### Scenario: Player range overlap filter
- **WHEN** the user selects a player-count range of 3 to 5
- **THEN** the list shows only games that can be played by 3 to 5 players according to their supported player range

### Requirement: Filter by play time range
The filter controls SHALL provide a two-handle range slider with discrete steps (0, 5, 10, 15, 30, 45, 60, 90, 120, 240, 360, 480, 720 minutes). The filter SHALL apply against the effective play time (`maxplaytime` or `minplaytime`), and the list SHALL update immediately.

#### Scenario: Play time range filter
- **WHEN** the user selects a play-time range
- **THEN** the list shows only games whose effective play time falls within the selected range

### Requirement: Filter by own or BGG rating range
The filter controls SHALL provide a two-handle range slider from 0 to 10 in 0.5 steps. The effective rating SHALL be the user's own rating when set, otherwise `bayesaverage`. Only games whose effective rating falls within the selected range SHALL be shown, and the list SHALL update immediately.

#### Scenario: Rating filter prefers own rating
- **WHEN** the user has rated a game and selects a rating range
- **THEN** the game is included or excluded based on the user's own rating

### Requirement: Combined filters use AND logic
Multiple active filters and search text SHALL be combined with AND logic. The list SHALL update immediately whenever any criterion changes.

#### Scenario: Search plus filters combine with AND
- **WHEN** the user enters search text and activates a sub-type filter
- **THEN** only items that match both the search text and the selected sub-type are shown
