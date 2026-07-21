# ci-cd Specification

## Purpose

Defines the continuous integration and release automation for the project: per-push test gate, per-push compilation for supported target platforms, and tag-based release builds that attach Android and Linux artifacts.
## Requirements
### Requirement: CI runs the full test suite on every push
A GitHub Actions workflow SHALL run the full test suite on every push. The build pipeline SHALL fail if any test fails, and no artifacts SHALL be built unless all tests pass.

#### Scenario: Push triggers test gate
- **WHEN** code is pushed to the repository
- **THEN** the CI workflow runs `flutter test` and fails the pipeline if tests fail

### Requirement: CI compiles for supported target platforms on every push
Every push SHALL trigger a GitHub Actions workflow that compiles the app for the supported target platforms.

#### Scenario: Linux and Android compilation on push
- **WHEN** code is pushed to the repository
- **THEN** the workflow compiles the app for Linux Desktop and Android

### Requirement: Tag-based release builds and attaches artifacts
Pushing any tag starting with `v` SHALL trigger a release workflow that builds release artifacts and attaches them to the created GitHub Release automatically. The release workflow SHALL derive `versionName` and `versionCode` from the Git tag so that the built app reports the same version as the release.

#### Scenario: Version tag creates release with assets
- **WHEN** a tag matching `v*` is pushed
- **THEN** a GitHub Release is created with the Android APK and Linux bundle attached

#### Scenario: Version tag creates release with matching app version
- **WHEN** a tag matching `v*` is pushed
- **THEN** the Android APK's `versionName` equals the tag without the `v` prefix
- **AND** the Android APK's `versionCode` is a monotonically increasing integer derived from the tag or the commit count

### Requirement: Release workflow has required permissions
The release workflow SHALL declare the permissions needed to create releases and upload assets. The repository's GitHub Actions settings SHALL allow these permissions or use an appropriate token.

#### Scenario: Release upload succeeds
- **WHEN** the release workflow runs
- **THEN** it can create the release and upload artifacts without a `403` permission error

