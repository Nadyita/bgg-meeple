# android-release-signing Specification

## Purpose

Defines how the BGG Meeple Android app is signed for release builds, ensuring that APKs and App Bundles can be upgraded in-place and distributed consistently.

## Requirements

### Requirement: Release builds use a stable signing key

The Android release build SHALL be signed with a dedicated, project-owned keystore that is reused for every release build. Debug signing keys SHALL NOT be used for release builds.

#### Scenario: Installing a release update

- **WHEN** a user installs a newer release build of the app
- **THEN** Android accepts the update because the APK is signed with the same key as the previously installed version

### Requirement: Keystore credentials are not committed to version control

The signing keystore file and its passwords SHALL NOT be stored in the Git repository. Credentials SHALL be provided via environment variables or a secure secret store at build time.

#### Scenario: Repository contains no secrets

- **WHEN** the repository is cloned by a contributor
- **THEN** no keystore file or plaintext password is present in the source tree

### Requirement: Release signing configuration is documented and reproducible

The project SHALL document how release builds are signed and SHALL declare the signing configuration in the Android Gradle build file so that CI can reproduce release builds when the keystore and credentials are provided.

#### Scenario: Contributor builds release with credentials

- **WHEN** a maintainer runs the documented release build command with valid credentials
- **THEN** the resulting APK/AAB is signed with the configured release key

## Notes

- The release keystore must be backed up securely; losing it prevents future updates.
- CI workflows should pass credentials via environment variables injected from repository secrets.
