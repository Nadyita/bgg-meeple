# search-and-filter delta spec

## Purpose

Extends the player count filter so the user can choose whether it matches the publisher player count, the BGG-recommended player count, or the BGG-best player count.

## ADDED Requirements

### Requirement: Player count filter supports three modes

The filter panel SHALL provide a segmented button that lets the user switch the player count filter between `publisher`, `recommended`, and `best`. The default mode SHALL be `publisher`. The selected mode SHALL persist with the rest of the collection view state.

#### Scenario: Switch filter mode

- **GIVEN** the user opened the filter panel
- **WHEN** the user taps the `recommended` segment
- **THEN** the player count slider filters games by their BGG-recommended player count

#### Scenario: Default mode is publisher

- **GIVEN** the user has never changed the player count filter mode
- **WHEN** the filter panel is opened
- **THEN** the `publisher` segment is selected and the slider filters by publisher player count

### Requirement: Slider range is preserved when switching modes

Changing the player count filter mode SHALL keep the current slider values. Only the data source for the filter evaluation SHALL change.

#### Scenario: Preserve slider values across modes

- **GIVEN** the user set the player count slider to 3–5 while in `publisher` mode
- **WHEN** the user switches to `recommended` mode
- **THEN** the slider still shows 3–5
- **AND** games are filtered by whether their recommended player count overlaps 3–5

### Requirement: Clearing filters does not reset the mode

The filter panel's "Clear" button and the search-field clear action SHALL reset the player count slider values to their default (no filter), but SHALL NOT change the selected player count filter mode.

#### Scenario: Clear keeps mode

- **GIVEN** the user selected `best` mode and set the slider to 2–4
- **WHEN** the user clears the filters
- **THEN** the slider returns to the unfiltered state
- **AND** the `best` segment is still selected

### Requirement: Filter evaluates by selected mode with fallback

When the player count filter mode is `recommended`, a game SHALL match if its `recommendedPlayerCountMin`/`recommendedPlayerCountMax` overlap the selected range; if the recommended range is missing, the publisher `minPlayers`/`maxPlayers` SHALL be used as a fallback. When the mode is `best`, it SHALL match by `bestPlayerCountMin`/`bestPlayerCountMax`; if the best range is missing, the recommended range SHALL be used as a fallback, and if that is also missing, the publisher range SHALL be used. When the mode is `publisher`, it SHALL match by `minPlayers`/`maxPlayers` as before.

#### Scenario: Recommended mode filters correctly

- **GIVEN** the player count filter mode is `recommended` and the slider is set to 4–6
- **AND** a game has a recommended player count of "4, 6–10, 12" (min 4, max 12)
- **WHEN** the filter is applied
- **THEN** the game is included because the ranges overlap

#### Scenario: Missing recommended values fall back to publisher

- **GIVEN** the player count filter mode is `recommended` and the slider is set to 3–4
- **AND** a game has no recommended player count data
- **AND** the game's publisher range is 2–5
- **WHEN** the filter is applied
- **THEN** the game is included because the publisher range overlaps 3–4

#### Scenario: Missing best values fall back to recommended and publisher

- **GIVEN** the player count filter mode is `best` and the slider is set to 3–4
- **AND** a game has no best player count data
- **AND** the game has a recommended player count of "4, 6–10, 12"
- **WHEN** the filter is applied
- **THEN** the game is included because the recommended range overlaps 3–4

#### Scenario: Open-ended ranges are handled

- **GIVEN** the player count filter mode is `best` and the slider is set to 4–4
- **AND** a game has a best player count of "5+" (min 5, max null)
- **WHEN** the filter is applied
- **THEN** the game is excluded because the best range does not overlap 4–4

### Requirement: Filter panel label matches selected mode

The filter panel SHALL use a `SegmentedButton` to indicate the current player count filter mode. The label previously shown above the slider is not required because the SegmentedButton already communicates the selected source.

#### Scenario: Segmented button shows active mode

- **GIVEN** the user opened the filter panel
- **WHEN** the player count filter mode is `recommended`
- **THEN** the segmented button shows the `recommended` segment selected
- **AND** no separate "Players" label is shown above the slider

### Requirement: Persist mode with collection view

The selected player count filter mode SHALL be serialized together with the `CollectionView` and restored on app restart.

#### Scenario: Mode survives restart

- **GIVEN** the user selected `recommended` mode
- **WHEN** the app is restarted
- **THEN** the filter panel still shows `recommended` selected
