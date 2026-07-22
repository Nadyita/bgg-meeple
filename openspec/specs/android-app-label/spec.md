# android-app-label Specification

## Purpose

Defines the human-readable launcher label for the BGG Meeple app on Android.

## Requirements

### Requirement: Android app shows the readable brand name

The Android application label SHALL be `BGG Meeple`, matching the brand name used across project documentation.

#### Scenario: Android launcher shows "BGG Meeple"

- **WHEN** the app is installed on an Android device
- **THEN** the home screen / app drawer displays the label `BGG Meeple`

### Requirement: Android app label is protected by an automated check

The project SHALL include an automated test that verifies the `application android:label` value in `AndroidManifest.xml` remains `BGG Meeple`.

#### Scenario: Contributor changes the manifest label

- **WHEN** a contributor modifies `AndroidManifest.xml`
- **THEN** the test suite fails if the `android:label` no longer equals `BGG Meeple`

## Notes

- The label is intentionally kept in `AndroidManifest.xml` rather than a string resource because the project does not currently require locale-specific Android launcher labels.
