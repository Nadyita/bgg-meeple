# android-app-label delta spec

## Purpose

Updates the human-readable launcher label for the app on Android from `BGG Meeple` to `MyMeeple`.

## MODIFIED Requirements

### Requirement: Android app shows the readable brand name

The Android application label SHALL be `MyMeeple`, matching the brand name used across project documentation.

#### Scenario: Android launcher shows "MyMeeple"

- **WHEN** the app is installed on an Android device
- **THEN** the home screen / app drawer displays the label `MyMeeple`

### Requirement: Android app label is protected by an automated check

The project SHALL include an automated test that verifies the `application android:label` value in `AndroidManifest.xml` remains `MyMeeple`.

#### Scenario: Contributor changes the manifest label

- **WHEN** a contributor modifies `AndroidManifest.xml`
- **THEN** the test suite fails if the `android:label` no longer equals `MyMeeple`
