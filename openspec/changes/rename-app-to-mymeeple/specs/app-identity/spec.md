# app-identity delta spec

## Purpose

Defines the canonical user-facing name of the app across platforms, localizations, and project documentation. This is a new capability introduced to centralize the `MyMeeple` brand name.

## ADDED Requirements

### Requirement: The app is branded as MyMeeple

The app SHALL display the name `MyMeeple` to users everywhere a human-readable app name is shown.

#### Scenario: App title follows the canonical brand name

- **GIVEN** the user launches the app on any supported platform
- **WHEN** the app title is displayed in the window title, launcher, task switcher, or settings
- **THEN** the displayed name is `MyMeeple`

#### Scenario: App title is localized but consistent

- **GIVEN** the device language is German or English
- **WHEN** the app title is rendered through `AppLocalizations`
- **THEN** the title is `MyMeeple` in both languages

### Requirement: Project documentation uses the new brand name

All user-facing project documentation SHALL refer to the app as `MyMeeple` instead of `BGG Meeple`.

#### Scenario: README and requirements index reflect the new name

- **GIVEN** a contributor or user reads `README.md` or `REQUIREMENTS.md`
- **WHEN** they look for the app name
- **THEN** the documents consistently use `MyMeeple`
