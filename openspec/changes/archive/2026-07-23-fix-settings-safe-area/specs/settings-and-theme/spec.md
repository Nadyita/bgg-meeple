# settings-and-theme Delta Specification

## MODIFIED Requirements

### Requirement: Settings content respects bottom safe area
The settings screen SHALL keep all scrollable content fully visible above the system navigation bar on Android by applying bottom safe-area padding to the scrollable area.

#### Scenario: Last settings item visible above navigation bar
- **GIVEN** the user is on the settings screen
- **WHEN** the device has a bottom system navigation bar
- **THEN** the last item in the scrollable settings list is not obscured by the navigation bar

#### Scenario: Existing page padding is preserved
- **GIVEN** the user is on the settings screen
- **THEN** the settings screen still keeps a 16 logical pixel margin around the scrollable content where no system inset applies
