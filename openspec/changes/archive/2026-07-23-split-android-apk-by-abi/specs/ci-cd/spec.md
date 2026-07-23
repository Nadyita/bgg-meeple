This is a delta spec capturing the changes made to the `ci-cd` capability.

## MODIFIED Requirements

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
