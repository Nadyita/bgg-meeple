## ADDED Requirements

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
