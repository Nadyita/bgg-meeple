This is a delta spec capturing the changes made to the `ci-cd` capability.

## MODIFIED Requirements

### Requirement: Tag-based release builds and attaches artifacts
Pushing any tag starting with `v` SHALL trigger a release workflow that builds release artifacts and attaches them to the created GitHub Release automatically. The release workflow SHALL derive `versionName` and `versionCode` from the Git tag so that the built app reports the same version as the release.

#### Scenario: Version tag creates release with assets
- **WHEN** a tag matching `v*` is pushed
- **THEN** a GitHub Release is created with the Android APK and Linux bundle attached

#### Scenario: Version tag creates release with matching app version
- **WHEN** a tag matching `v*` is pushed
- **THEN** the Android APK's `versionName` equals the tag without the `v` prefix
- **AND** the Android APK's `versionCode` is a monotonically increasing integer derived from the tag or the commit count
