# settings-and-theme delta spec

## Purpose

Adds a setting to control whether the snackbar hint is shown when a player filter is added.

## ADDED Requirements

### Requirement: Toggle player-filter hint snackbar

The settings screen SHALL contain a toggle that enables or disables the snackbar hint shown after adding a player to the collection filter. The default SHALL be enabled.

#### Scenario: Disable hint

- **GIVEN** the user is on the settings screen
- **WHEN** the user turns off the "Show player filter hint" toggle
- **THEN** adding a player filter no longer shows the hint snackbar

#### Scenario: Hint setting persists

- **GIVEN** the user disabled the hint
- **WHEN** the app is restarted
- **THEN** the hint remains disabled
