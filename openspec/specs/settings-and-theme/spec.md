# settings-and-theme Specification

## Purpose

Defines the settings screen, including BGG account and manual API token inputs, dark/light theme mode toggle, and the app-wide font size setting.
## Requirements
### Requirement: Settings screen contains account and token inputs
The settings screen SHALL be accessible from the main view and SHALL contain inputs for the BGG username, password, and manual API bearer token.

#### Scenario: Open settings and edit credentials
- **WHEN** the user navigates to the settings screen
- **THEN** BGG username, password, and API token inputs are visible and editable

### Requirement: Theme mode toggle persists
The user SHALL be able to switch between dark and light mode in settings. The chosen theme mode SHALL persist across app restarts.

#### Scenario: Theme change persists
- **WHEN** the user selects dark mode and restarts the app
- **THEN** the app starts in dark mode

### Requirement: Settings screen contains font size control
The settings screen SHALL offer a font size setting with 5 levels where the middle level is the default. The setting SHALL apply app-wide and persist across app restarts.

#### Scenario: Font size setting is available
- **WHEN** the user opens the settings screen
- **THEN** a font size control is visible and its value persists after restart

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

