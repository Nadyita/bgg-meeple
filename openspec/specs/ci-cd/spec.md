# ci-cd Specification

## Purpose

Defines the continuous integration and release automation for the project: per-push test gate, per-push compilation for supported target platforms, and tag-based release builds that attach per-architecture Android APKs and a Linux bundle.

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

### Requirement: Tag-based release builds per-ABI Android APKs

Pushing any tag starting with `v` SHALL trigger a release workflow that builds Android release APKs split by ABI and attaches them to the created GitHub Release automatically. The release workflow SHALL derive `versionName` and `versionCode` from the Git tag so that the built app reports the same version as the release.

#### Scenario: Version tag creates release with per-ABI APK assets

- **WHEN** a tag matching `v*` is pushed
- **THEN** it builds APKs for `armeabi-v7a`, `arm64-v8a`, and `x86_64`
- **AND** it attaches the per-ABI APKs to the GitHub Release

#### Scenario: Version tag creates APKs with matching app version

- **WHEN** a tag matching `v*` is pushed
- **THEN** each APK's `versionName` equals the tag without the `v` prefix
- **AND** each APK's `versionCode` is a monotonically increasing integer derived from the tag

### Requirement: Release workflow has required permissions

The release workflow SHALL declare the permissions needed to create releases and upload assets. The repository's GitHub Actions settings SHALL allow these permissions or use an appropriate token.

#### Scenario: Release upload succeeds

- **WHEN** the release workflow runs
- **THEN** it can create the release and upload the split APKs and Linux bundle without a `403` permission error
